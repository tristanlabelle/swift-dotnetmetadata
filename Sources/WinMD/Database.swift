import Foundation

public class Database {
    struct MetadataRoot {
        var majorVersion: UInt16, minorVersion: UInt16
        var versionString: String
        var flags: UInt16
        var streamHeaders: [String: MetadataStreamHeader] = [:]
    }

    let file: Data?
    let heapSizes: UInt8

    var stringOffsetSize: Int { (heapSizes & 1) == 0 ? 2 : 4 }
    var guidOffsetSize: Int { (heapSizes & 2) == 0 ? 2 : 4 }
    var blobOffsetSize: Int { (heapSizes & 4) == 0 ? 2 : 4 }

    public let stringHeap: StringHeap
    public let guidHeap: GuidHeap
    public let blobHeap: BlobHeap

    public let tableRowCounts: [Int]

    // In TableIndex order
    public var moduleTable: Table<Module>!
    public var typeRefTable: Table<TypeRef>!
    public var typeDefTable: Table<TypeDef>!
    public var fieldTable: Table<Field>!

    public init(file: Data) throws {
        self.file = file
        let data = file.withUnsafeBytes { $0 }
        let peView = try PE.View(file: data)

        let cliHeader = peView.resolve(peView.dataDirectories[14]) // IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR
            .bindMemory(offset: 0, to: PE.ImageCor20Header.self)
        guard cliHeader.pointee.cb == MemoryLayout<PE.ImageCor20Header>.stride else { throw InvalidFormatError.invalidCLIHeader }

        let metadataSection = peView.resolve(virtualAddress: cliHeader.pointee.metaData.virtualAddress, size: cliHeader.pointee.metaData.size)
        let metadataRoot = try Self.readMetadataRoot(metadataSection: metadataSection)

        stringHeap = StringHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#Strings"]))
        guidHeap = GuidHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#GUID"]))
        blobHeap = BlobHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#Blob"]))

        var tablesStreamRemainder = Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#~"])
        let tablesStreamHeader = tablesStreamRemainder.consume(type: MetadataTablesStreamHeader.self)
        guard tablesStreamHeader.pointee.majorVersion == 2 && tablesStreamHeader.pointee.minorVersion == 0 else {
            throw InvalidFormatError.invalidCLIHeader
        }

        tableRowCounts = (0 ..< 64).map {
            let isTablePresent = (tablesStreamHeader.pointee.valid & (UInt64(1) << $0)) != 0
            return isTablePresent ? Int(tablesStreamRemainder.consume(type: UInt32.self).pointee) : 0
        }

        heapSizes = tablesStreamHeader.pointee.heapSizes

        moduleTable = consumeTable(buffer: &tablesStreamRemainder)
        typeRefTable = consumeTable(buffer: &tablesStreamRemainder)
        typeDefTable = consumeTable(buffer: &tablesStreamRemainder)
        fieldTable = consumeTable(buffer: &tablesStreamRemainder)
    }

    public convenience init(url: URL) throws {
        try self.init(file: try Data(contentsOf: url, options: .mappedIfSafe))
    }

    static func getStream(metadataSection: UnsafeRawBufferPointer, header: MetadataStreamHeader?) -> UnsafeRawBufferPointer {
        guard let header = header else { return UnsafeRawBufferPointer.empty }
        return metadataSection.sub(offset: Int(header.offset), count: Int(header.size))
    }

    static func readMetadataRoot(metadataSection: UnsafeRawBufferPointer) throws -> MetadataRoot {
        var remainder = metadataSection

        let beforeVersion = remainder.consume(type: MetadataRoot_BeforeVersion.self)
        guard beforeVersion.pointee.signature == 0x424a5342 else { throw InvalidFormatError.invalidCLIHeader }

        let versionStringPaddedLength = (Int(beforeVersion.pointee.length) + 3) & ~0x3
        let versionStringPaddedBytes = remainder.consume(count: versionStringPaddedLength)
        let versionString = String(bytes: versionStringPaddedBytes.sub(offset: 0, count: Int(beforeVersion.pointee.length)), encoding: .utf8)!

        let afterVersion = remainder.consume(type: MetadataRoot_AfterVersion.self)

        var streamHeaders: [String: MetadataStreamHeader] = [:]
        for _ in 0 ..< Int(afterVersion.pointee.streams) {
            let streamHeader = remainder.consume(type: MetadataStreamHeader.self)
            let streamName = remainder.consumeDwordPaddedUTF8String()
            streamHeaders[streamName] = streamHeader.pointee
        }

        return MetadataRoot(
            majorVersion: beforeVersion.pointee.majorVersion,
            minorVersion: beforeVersion.pointee.minorVersion,
            versionString: versionString,
            flags: afterVersion.pointee.flags,
            streamHeaders: streamHeaders)
    }

    func consumeStringRef(buffer: inout UnsafeRawBufferPointer) -> StringRef {
        let offset = (heapSizes & 0x1) == 0
            ? Int(buffer.consume(type: UInt16.self).pointee)
            : Int(buffer.consume(type: UInt32.self).pointee)
        return StringRef(heap: stringHeap, offset: offset)
    }

    func consumeGuidRef(buffer: inout UnsafeRawBufferPointer) -> GuidRef {
        let offset = (heapSizes & 0x2) == 0
            ? Int(buffer.consume(type: UInt16.self).pointee)
            : Int(buffer.consume(type: UInt32.self).pointee)
        return GuidRef(heap: guidHeap, offset: offset)
    }

    func consumeBlobRef(buffer: inout UnsafeRawBufferPointer) -> BlobRef {
        let offset = (heapSizes & 0x4) == 0
            ? Int(buffer.consume(type: UInt16.self).pointee)
            : Int(buffer.consume(type: UInt32.self).pointee)
        return BlobRef(heap: blobHeap, offset: offset)
    }

    func consumeTable<Row>(buffer: inout UnsafeRawBufferPointer) -> Table<Row> where Row: Record {
        let rowCount = tableRowCounts[Int(Row.tableIndex.rawValue)]
        let size = Row.getSize(database: self) * rowCount
        return Table(buffer: buffer.consume(count: size), database: self)
    }

    func getTableRowIndexSize(_ tableIndex: TableIndex) -> Int {
        tableRowCounts[Int(tableIndex.rawValue)] < 0x10000 ? 2 : 4
    }
    
    func getTableRowIndexSize<Row>(_ type: Row.Type) -> Int where Row: Record {
        getTableRowIndexSize(Row.tableIndex)
    }

    func getCodedIndexSize<T>(_ type: T.Type) -> Int where T : CodedIndex {
        let tagBitCount = Int.bitWidth - T.tables.count.leadingZeroBitCount
        let maxRowCount = T.tables.compactMap { $0 }.map { tableRowCounts[Int($0.rawValue)] }.max()!
        return maxRowCount < (1 << (16 - tagBitCount)) ? 2 : 4
    }

    func consumeCodedIndex<T>(buffer: inout UnsafeRawBufferPointer) -> T where T : CodedIndex {
        let tagBitCount = Int.bitWidth - T.tables.count.leadingZeroBitCount

        let codedValue: Int
        let indexBitCount: Int
        if getCodedIndexSize(T.self) == 2 {
            codedValue = Int(buffer.consume(type: UInt16.self).pointee)
            indexBitCount = 16 - tagBitCount
        }
        else {
            codedValue = Int(buffer.consume(type: UInt32.self).pointee)
            indexBitCount = 32 - tagBitCount
        }

        let tag = codedValue >> indexBitCount
        let index = codedValue & ((1 << indexBitCount) - 1)
        return T.create(database: self, tag: tag, index: index) 
    }
}

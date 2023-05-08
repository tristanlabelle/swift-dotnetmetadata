import Foundation

public class Database {
    struct MetadataRoot {
        var majorVersion: UInt16, minorVersion: UInt16
        var versionString: String
        var flags: UInt16
        var streamHeaders: [String: MetadataStreamHeader] = [:]
    }

    let file: Data?
    let dimensions: Dimensions

    public let stringHeap: StringHeap
    public let guidHeap: GuidHeap
    public let blobHeap: BlobHeap

    // In TableIndex order
    public var moduleTable: Table<Module>!
    public var typeRefTable: Table<TypeRef>!
    public var typeDefTable: Table<TypeDef>!
    public var fieldTable: Table<Field>!
    public var methodDefTable: Table<MethodDef>!

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

        let tableRowCounts = (0 ..< 64).map {
            let isTablePresent = (tablesStreamHeader.pointee.valid & (UInt64(1) << $0)) != 0
            return isTablePresent ? tablesStreamRemainder.consume(type: UInt32.self).pointee : UInt32(0)
        }

        dimensions = Dimensions(heapSizes: tablesStreamHeader.pointee.heapSizes, tableRowCounts: tableRowCounts)

        moduleTable = consumeTable(buffer: &tablesStreamRemainder, dimensions: dimensions)
        typeRefTable = consumeTable(buffer: &tablesStreamRemainder, dimensions: dimensions)
        typeDefTable = consumeTable(buffer: &tablesStreamRemainder, dimensions: dimensions)
        fieldTable = consumeTable(buffer: &tablesStreamRemainder, dimensions: dimensions)
        methodDefTable = consumeTable(buffer: &tablesStreamRemainder, dimensions: dimensions)
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

    func consumeTable<Row>(buffer: inout UnsafeRawBufferPointer, dimensions: Dimensions) -> Table<Row> where Row: Record {
        let rowCount = dimensions.getRowCount(Row.tableIndex)
        let size = Row.getSize(dimensions: dimensions) * rowCount
        return Table(buffer: buffer.consume(count: size), dimensions: dimensions)
    }

    public func resolve(_ offset: HeapOffset<StringHeap>) -> String {
        stringHeap.resolve(at: offset.value)
    }
    
    public func resolve(_ offset: HeapOffset<GuidHeap>) -> UUID {
        guidHeap.resolve(at: offset.value)
    }
    
    public func resolve(_ offset: HeapOffset<BlobHeap>) -> UnsafeRawBufferPointer {
        blobHeap.resolve(at: offset.value)
    }
}

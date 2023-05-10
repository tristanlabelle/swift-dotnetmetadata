import Foundation

public class Database {
    struct MetadataRoot {
        var majorVersion: UInt16, minorVersion: UInt16
        var versionString: String
        var flags: UInt16
        var streamHeaders: [String: MetadataStreamHeader] = [:]
    }

    let file: Data?
    public let heaps: Heaps
    public let tables: Tables

    public init(file: Data) throws {
        self.file = file
        let data = file.withUnsafeBytes { $0 }
        let peView = try PE.View(file: data)

        let cliHeader = peView.resolve(peView.dataDirectories[14]) // IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR
            .bindMemory(offset: 0, to: PE.ImageCor20Header.self)
        guard cliHeader.pointee.cb == MemoryLayout<PE.ImageCor20Header>.stride else { throw InvalidFormatError.invalidCLIHeader }

        let metadataSection = peView.resolve(virtualAddress: cliHeader.pointee.metaData.virtualAddress, size: cliHeader.pointee.metaData.size)
        let metadataRoot = try Self.readMetadataRoot(metadataSection: metadataSection)

        heaps = Heaps(
            string: StringHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#Strings"])),
            guid: GuidHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#GUID"])),
            blob: BlobHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#Blob"])))

        var tablesStreamRemainder = Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#~"])
        let tablesStreamHeader = tablesStreamRemainder.consume(type: MetadataTablesStreamHeader.self)
        guard tablesStreamHeader.pointee.majorVersion == 2 && tablesStreamHeader.pointee.minorVersion == 0 else {
            throw InvalidFormatError.invalidCLIHeader
        }

        let tableRowCounts = (0 ..< TableIndex.count).map {
            let isTablePresent = (tablesStreamHeader.pointee.valid & (TableIndex.BitSet(1) << $0)) != 0
            return isTablePresent ? tablesStreamRemainder.consume(type: UInt32.self).pointee : UInt32(0)
        }

        let dimensions = Dimensions(heapSizes: tablesStreamHeader.pointee.heapSizes, tableRowCounts: tableRowCounts)
        tables = Tables(buffer: tablesStreamRemainder, dimensions: dimensions)
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
}

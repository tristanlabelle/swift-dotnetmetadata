import Foundation

public class Database {
    struct InvalidFormatError : Error {}

    struct MetadataRoot {
        var majorVersion: UInt16, minorVersion: UInt16
        var versionString: String
        var flags: UInt16
        var streamHeaders: [String: CLI.MetadataStreamHeader] = [:]
    }

    let file: Data?
    var stringHeap: StringHeap { fatalError() }
    var guidHeap: GuidHeap { fatalError() }
    var blobHeap: BlobHeap { fatalError() }

    public init(file: Data) throws {
        self.file = file
        let data = file.withUnsafeBytes { $0 }
        let peView = try PE.View(file: data)
        let cliHeader = peView.resolve(peView.dataDirectories[14]) // IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR
            .bindMemory(offset: 0, to: PE.ImageCor20Header.self)
        guard cliHeader.pointee.cb == MemoryLayout<PE.ImageCor20Header>.stride else { throw InvalidFormatError() }

        let metadataSection = peView.resolve(virtualAddress: cliHeader.pointee.metaData.virtualAddress, size: cliHeader.pointee.metaData.size)
        let metadataRoot = try Self.readMetadataRoot(metadataSection: metadataSection)

        // Read the metadata table stream header
        let metadataTablesStreamHeader = metadataRoot.streamHeaders["#~"]!
        let metadataTablesStream = metadataSection.sub(offset: Int(metadataTablesStreamHeader.offset), count: Int(metadataTablesStreamHeader.size))
        try Self.readMetadataTablesStream(stream: metadataTablesStream)
    }

    public convenience init(url: URL) throws {
        try self.init(file: try Data(contentsOf: url, options: .mappedIfSafe))
    }

    static func readMetadataRoot(metadataSection: UnsafeRawBufferPointer) throws -> MetadataRoot {
        var remainder = metadataSection

        let beforeVersion = remainder.consume(type: CLI.MetadataRoot_BeforeVersion.self)
        guard beforeVersion.pointee.signature == 0x424a5342 else { throw InvalidFormatError() }

        let versionString = remainder.consumeNulPaddedUTF8String(maxLength: Int(beforeVersion.pointee.length))

        let afterVersion = remainder.consume(type: CLI.MetadataRoot_AfterVersion.self)

        print(afterVersion.pointee.streams)

        var streamHeaders: [String: CLI.MetadataStreamHeader] = [:]
        for _ in 0 ..< Int(afterVersion.pointee.streams) {
            let streamHeader = remainder.consume(type: CLI.MetadataStreamHeader.self)
            let streamName = remainder.consumeNulPaddedUTF8String(maxLength: 4)
            print("Stream '\(streamName)': offset=\(streamHeader.pointee.offset), size=\(streamHeader.pointee.size)")
            streamHeaders[streamName] = streamHeader.pointee
        }

        return MetadataRoot(
            majorVersion: beforeVersion.pointee.majorVersion,
            minorVersion: beforeVersion.pointee.minorVersion,
            versionString: versionString,
            flags: afterVersion.pointee.flags,
            streamHeaders: streamHeaders)
    }

    static func readMetadataTablesStream(stream: UnsafeRawBufferPointer) throws {
        var remainder = stream
        let header = remainder.consume(type: CLI.MetadataTablesStreamHeader.self)
        guard header.pointee.majorVersion == 2 && header.pointee.minorVersion == 0 else {
            throw InvalidFormatError()
        }

        var rowCounts: [UInt32] = Array(repeating: 0, count: 64)
        for i in 0 ..< rowCounts.count {
            if (header.pointee.valid & (UInt64(1) << i)) != 0 {
                rowCounts[i] = remainder.consume(type: UInt32.self).pointee;
            }
        }

        let stringIndexSize = (header.pointee.heapSizes & 0x01) == 0 ? 2 : 4;
        let guidIndexSize = (header.pointee.heapSizes & 0x02) == 0 ? 2 : 4;
        let blobIndexSize = (header.pointee.heapSizes & 0x04) == 0 ? 2 : 4;
        print(rowCounts.debugDescription)
    }
}

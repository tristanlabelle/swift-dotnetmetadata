import CInterop
import Foundation

/// A view of the CLI metadata embedded in a DotNetMDFormat file.
public final class ModuleFile {
    private struct MetadataRoot {
        var majorVersion: UInt16, minorVersion: UInt16
        var versionString: String
        var flags: UInt16
        var streamHeaders: [String: MetadataStreamHeader] = [:]
    }

    private let data: Data
    public let heaps: Heaps
    public let tables: Tables

    public init(data: Data) throws {
        self.data = data
        let buffer = data.withUnsafeBytes { $0 }
        let buffer2 = data.withUnsafeBytes { $0 }
        guard buffer2.baseAddress == buffer.baseAddress && buffer2.count == buffer.count else {
            fatalError("ModuleFile data is not pinned")
        }

        let peView = try PEView(file: buffer)

        let cliHeader = peView.resolve(peView.dataDirectories[Int(CINTEROP_IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR)])
            .bindMemory(offset: 0, to: CINTEROP_IMAGE_COR20_HEADER.self)
        guard cliHeader.pointee.cb == MemoryLayout<CINTEROP_IMAGE_COR20_HEADER>.stride else { throw InvalidFormatError.cliHeader }

        let metadataSection = peView.resolve(virtualAddress: cliHeader.pointee.MetaData.VirtualAddress, size: cliHeader.pointee.MetaData.Size)
        let metadataRoot = try Self.readMetadataRoot(metadataSection: metadataSection)

        heaps = Heaps(
            string: StringHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#Strings"])),
            guid: GuidHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#GUID"])),
            blob: BlobHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#Blob"])))

        var tablesStreamRemainder = Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#~"])
        let tablesStreamHeader = tablesStreamRemainder.consume(type: MetadataTablesStreamHeader.self)
        guard tablesStreamHeader.pointee.MajorVersion == 2 && tablesStreamHeader.pointee.MinorVersion == 0 else {
            throw InvalidFormatError.cliHeader
        }

        let tableRowCounts = (0 ..< TableID.count).map {
            let isTablePresent = (tablesStreamHeader.pointee.Valid & (TableID.BitSet(1) << $0)) != 0
            return isTablePresent ? tablesStreamRemainder.consume(type: UInt32.self).pointee : UInt32(0)
        }

        let tableSizes = TableSizes(heapSizingBits: tablesStreamHeader.pointee.HeapSizes, tableRowCounts: tableRowCounts)
        tables = Tables(buffer: tablesStreamRemainder, sizes: tableSizes, sortedBits: tablesStreamHeader.pointee.Sorted)
    }

    public convenience init(url: URL) throws {
        try self.init(data: try Data(contentsOf: url, options: .mappedIfSafe))
    }

    private static func getStream(metadataSection: UnsafeRawBufferPointer, header: MetadataStreamHeader?) -> UnsafeRawBufferPointer {
        guard let header = header else { return UnsafeRawBufferPointer.empty }
        return metadataSection.sub(offset: Int(header.Offset), count: Int(header.Size))
    }

    private static func readMetadataRoot(metadataSection: UnsafeRawBufferPointer) throws -> MetadataRoot {
        var remainder = metadataSection

        let beforeVersion = remainder.consume(type: MetadataRoot_BeforeVersion.self)
        guard beforeVersion.pointee.Signature == 0x424a5342 else { throw InvalidFormatError.cliHeader }

        let versionStringPaddedLength = (Int(beforeVersion.pointee.Length) + 3) & ~0x3
        let versionStringPaddedBytes = remainder.consume(count: versionStringPaddedLength)
        let versionString = String(bytes: versionStringPaddedBytes.sub(offset: 0, count: Int(beforeVersion.pointee.Length)), encoding: .utf8)!

        let afterVersion = remainder.consume(type: MetadataRoot_AfterVersion.self)

        var streamHeaders: [String: MetadataStreamHeader] = [:]
        for _ in 0 ..< Int(afterVersion.pointee.Streams) {
            let streamHeader = remainder.consume(type: MetadataStreamHeader.self)
            let streamName = remainder.consumeDwordPaddedUTF8String()
            streamHeaders[streamName] = streamHeader.pointee
        }

        return MetadataRoot(
            majorVersion: beforeVersion.pointee.MajorVersion,
            minorVersion: beforeVersion.pointee.MinorVersion,
            versionString: versionString,
            flags: afterVersion.pointee.Flags,
            streamHeaders: streamHeaders)
    }
}

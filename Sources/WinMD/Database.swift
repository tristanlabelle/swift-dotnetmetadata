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
        let metadataSection = try Self.getCliMetadataSection(file: data)
        let metadataRoot = try Self.readMetadataRoot(metadataSection: metadataSection)

        // Read the metadata table stream header
        let metadataTablesStreamHeader = metadataRoot.streamHeaders["#~"]!
        let metadataTablesStream = metadataSection.sub(offset: Int(metadataTablesStreamHeader.offset), count: Int(metadataTablesStreamHeader.size))
        try Self.readMetadataTablesStream(stream: metadataTablesStream)
    }

    public convenience init(url: URL) throws {
        try self.init(file: try Data(contentsOf: url, options: .mappedIfSafe))
    }

    static func getCliMetadataSection(file: UnsafeRawBufferPointer) throws -> UnsafeRawBufferPointer {
        let dosHeader = file.bindMemory(offset: 0, to: PE.ImageDOSHeader.self)
        guard dosHeader.pointee.e_signature == 0x5A4D else { throw InvalidFormatError() } // IMAGE_DOS_SIGNATURE

        let ntHeaders32 = file.bindMemory(offset: Int(dosHeader.pointee.e_lfanew), to: PE.ImageNTHeaders32.self)
        if ntHeaders32.pointee.FileHeader.NumberOfSections == 0
            || ntHeaders32.pointee.FileHeader.NumberOfSections > 100 {
            throw InvalidFormatError()
        }

        let sections: UnsafeBufferPointer<PE.ImageSectionHeader>
        let comVirtualAddress: UInt32;
        if ntHeaders32.pointee.OptionalHeader.Magic == 0x10B { // PE32
            comVirtualAddress = ntHeaders32.pointee.OptionalHeader.DataDirectory_14.VirtualAddress; // IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR
            sections = file.bindMemory(offset: Int(dosHeader.pointee.e_lfanew) + MemoryLayout<PE.ImageNTHeaders32>.stride,
                to: PE.ImageSectionHeader.self, count: Int(ntHeaders32.pointee.FileHeader.NumberOfSections))
        }
        else if ntHeaders32.pointee.OptionalHeader.Magic == 0x20B { // PE32+
            let ntHeaders32Plus = file.bindMemory(offset: Int(dosHeader.pointee.e_lfanew), to: PE.ImageNTHeaders32Plus.self)
            comVirtualAddress = ntHeaders32Plus.pointee.OptionalHeader.DataDirectory_14.VirtualAddress; // IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR
            sections = file.bindMemory(offset: Int(dosHeader.pointee.e_lfanew) + MemoryLayout<PE.ImageNTHeaders32Plus>.stride,
                to: PE.ImageSectionHeader.self, count: Int(ntHeaders32Plus.pointee.FileHeader.NumberOfSections))
        }
        else {
            throw InvalidFormatError()
        }

        let cliHeader = getRawData(file: file, sections: sections, rva: comVirtualAddress)!
            .bindMemory(offset: 0, to: PE.ImageCor20Header.self)
        guard cliHeader.pointee.cb == MemoryLayout<PE.ImageCor20Header>.stride else { throw InvalidFormatError() }

        return getRawData(file: file, sections: sections, rva: cliHeader.pointee.MetaData.VirtualAddress)!
    }
    
    static func getRawData(file: UnsafeRawBufferPointer, sections: UnsafeBufferPointer<PE.ImageSectionHeader>, rva: UInt32) -> UnsafeRawBufferPointer? {
        let section = sections.find(rva: rva)
        guard let section else { return nil }
        let sectionRawData = section.pointee.getRawData(file: file)
        return UnsafeRawBufferPointer(rebasing: sectionRawData[Int(rva - section.pointee.VirtualAddress)...])
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

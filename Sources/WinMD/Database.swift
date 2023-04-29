import Foundation

public class Database {
    struct InvalidFormatError : Error {}

    struct MetadataRoot {
        var majorVersion: UInt16, minorVersion: UInt16
        var versionString: String
        var flags: UInt16
        var streamHeaders: [String: UnsafeRawBufferPointer] = [:]
    }

    let file: Data?

    public init(file: Data) throws {
        self.file = file
        let data = file.withUnsafeBytes { $0 }
        let metadataSection = try Self.getCliMetadataSection(file: data)
        let metadataRoot = try Self.readMetadataRoot(metadataSection: metadataSection)

        // Read the metadata table stream header
        let metadataTablesStream = metadataRoot.streamHeaders["#~"]!

        var remainder = metadataTablesStream
        let metadataTablesStreamHeader = remainder.consume(type: CLI.MetadataTablesStreamHeader.self)
        guard metadataTablesStreamHeader.pointee.MajorVersion == 2 && metadataTablesStreamHeader.pointee.MinorVersion == 0 else {
            throw InvalidFormatError()
        }

        var metadataTableRowCounts: [UInt32] = Array(repeating: 0, count: 64)
        for i in 0 ..< metadataTableRowCounts.count {
            if (metadataTablesStreamHeader.pointee.Valid & (UInt64(1) << i)) != 0 {
                metadataTableRowCounts[i] = remainder.consume(type: UInt32.self).pointee;
            }
        }
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
                count: Int(ntHeaders32.pointee.FileHeader.NumberOfSections),
                to: PE.ImageSectionHeader.self)
        }
        else if ntHeaders32.pointee.OptionalHeader.Magic == 0x20B { // PE32+
            let ntHeaders32Plus = file.bindMemory(offset: Int(dosHeader.pointee.e_lfanew), to: PE.ImageNTHeaders32Plus.self)
            comVirtualAddress = ntHeaders32Plus.pointee.OptionalHeader.DataDirectory_14.VirtualAddress; // IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR
            sections = file.bindMemory(offset: Int(dosHeader.pointee.e_lfanew) + MemoryLayout<PE.ImageNTHeaders32Plus>.stride,
                count: Int(ntHeaders32Plus.pointee.FileHeader.NumberOfSections),
                to: PE.ImageSectionHeader.self)
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
        guard beforeVersion.pointee.Signature == 0x424a5342 else { throw InvalidFormatError() }
        
        let versionStringPtr = remainder.consume(type: UInt8.self, count: Int(beforeVersion.pointee.Length))
        let versionString = String(bytes: versionStringPtr, encoding: .utf16)!
        
        let afterVersion = remainder.consume(type: CLI.MetadataRoot_AfterVersion.self)

        var streamHeaders: [String: UnsafeRawBufferPointer] = [:]
        for _ in 0 ..< Int(afterVersion.pointee.Streams) {
            let streamHeader = remainder.consume(type: CLI.MetadataStreamHeader.self)
            let streamName = String(bytes: remainder.consume(type: UInt8.self, count: 4), encoding: .utf8)!
            streamHeaders[streamName] = metadataSection.sub(offset: Int(streamHeader.pointee.Offset), count: Int(streamHeader.pointee.Size))
        }

        return MetadataRoot(
            majorVersion: beforeVersion.pointee.MajorVersion,
            minorVersion: beforeVersion.pointee.MinorVersion,
            versionString: versionString,
            flags: afterVersion.pointee.Flags,
            streamHeaders: streamHeaders)
    }
}

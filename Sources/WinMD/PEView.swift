struct PEView {
    let file: UnsafeRawBufferPointer

    public let dosHeader: UnsafePointer<ImageDOSHeader>

    let ntHeaders_maybe32: UnsafePointer<ImageNTHeaders32>
    public var sixtyFourBits: Bool { ntHeaders_maybe32.pointee.optionalHeader.magic == 0x20B }
    public var ntHeaders32: UnsafePointer<ImageNTHeaders32>? { sixtyFourBits ? nil : ntHeaders_maybe32 }
    public var ntHeaders64: UnsafePointer<ImageNTHeaders64>? {
        sixtyFourBits ? UnsafeRawPointer(ntHeaders_maybe32).assumingMemoryBound(to: ImageNTHeaders64.self) : nil
    }

    public var dataDirectories: UnsafeBufferPointer<ImageDataDirectory> {
        let offset = sixtyFourBits
            ? MemoryLayout.offset(of: \ImageNTHeaders64.optionalHeader.dataDirectory_0)!
            : MemoryLayout.offset(of: \ImageNTHeaders32.optionalHeader.dataDirectory_0)!
        let firstDataDirectory = UnsafeRawPointer(ntHeaders_maybe32).advanced(by: offset).assumingMemoryBound(to: ImageDataDirectory.self)
        return UnsafeBufferPointer(start: firstDataDirectory, count: 16)
    }

    public let sections: [Section]

    init(file: UnsafeRawBufferPointer) throws {
        self.file = file
        self.dosHeader = file.bindMemory(offset: 0, to: ImageDOSHeader.self)
        guard dosHeader.pointee.e_signature == 0x5A4D else { throw InvalidFormatError.invalidDOSHeader } // IMAGE_DOS_SIGNATURE

        self.ntHeaders_maybe32 = file.bindMemory(offset: Int(dosHeader.pointee.e_lfanew), to: ImageNTHeaders32.self)

        let sectionHeaders: UnsafeBufferPointer<ImageSectionHeader>
        if ntHeaders_maybe32.pointee.optionalHeader.magic == 0x10B { // PE32
            sectionHeaders = file.bindMemory(offset: Int(dosHeader.pointee.e_lfanew) + MemoryLayout<ImageNTHeaders32>.stride,
                to: ImageSectionHeader.self, count: Int(ntHeaders_maybe32.pointee.fileHeader.numberOfSections))
        }
        else if ntHeaders_maybe32.pointee.optionalHeader.magic == 0x20B { // PE32+
            let ntHeaders64 = file.bindMemory(offset: Int(dosHeader.pointee.e_lfanew), to: ImageNTHeaders64.self)
            sectionHeaders = file.bindMemory(offset: Int(dosHeader.pointee.e_lfanew) + MemoryLayout<ImageNTHeaders64>.stride,
                to: ImageSectionHeader.self, count: Int(ntHeaders64.pointee.fileHeader.numberOfSections))
        }
        else {
            throw InvalidFormatError.invalidNTHeader
        }

        sections = (0 ..< sectionHeaders.count).map { sectionIndex in 
            let sectionHeader = sectionHeaders.baseAddress!.advanced(by: sectionIndex)
            let sectionData = file.sub(offset: Int(sectionHeader.pointee.pointerToRawData), count: Int(sectionHeader.pointee.sizeOfRawData))
            return Section(header: sectionHeader, data: sectionData)
        }
    }

    func resolve(virtualAddress: UInt32, size: UInt32) -> UnsafeRawBufferPointer {
        let section = sections.first { $0.contains(virtualAddress: virtualAddress) }!
        return section.resolve(virtualAddress: virtualAddress, size: size)
    }

    func resolve(_ dataDictionary: ImageDataDirectory) -> UnsafeRawBufferPointer {
        resolve(virtualAddress: dataDictionary.virtualAddress, size: dataDictionary.size)
    }
}

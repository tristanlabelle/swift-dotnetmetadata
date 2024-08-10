import DotNetMetadataCInterop

struct PEView {
    let file: UnsafeRawBufferPointer

    public let dosHeader: UnsafePointer<CINTEROP_IMAGE_DOS_HEADER>
    let peHeader: UnsafeRawBufferPointer

    var ntHeaders_maybe32: UnsafePointer<CINTEROP_IMAGE_NT_HEADERS32> {
        peHeader.bindMemory(offset: 0, to: CINTEROP_IMAGE_NT_HEADERS32.self)
    }

    public var fileHeader: UnsafePointer<CINTEROP_IMAGE_FILE_HEADER> {
        ntHeaders_maybe32.pointer(to: \.FileHeader)!
    }

    public var sixtyFourBits: Bool { ntHeaders_maybe32.pointee.OptionalHeader.Magic == CINTEROP_IMAGE_NT_OPTIONAL_HDR64_MAGIC }
    public var ntHeaders32: UnsafePointer<CINTEROP_IMAGE_NT_HEADERS32>? {
        sixtyFourBits ? nil : ntHeaders_maybe32
    }
    public var ntHeaders64: UnsafePointer<CINTEROP_IMAGE_NT_HEADERS64>? {
        sixtyFourBits ? peHeader.bindMemory(offset: 0, to: CINTEROP_IMAGE_NT_HEADERS64.self) : nil
    }

    public var ntOptionalHeaders32: UnsafePointer<CINTEROP_IMAGE_OPTIONAL_HEADER32>? {
        sixtyFourBits ? nil : ntHeaders_maybe32.pointer(to: \.OptionalHeader)
    }
    public var ntOptionalHeaders64: UnsafePointer<CINTEROP_IMAGE_OPTIONAL_HEADER64>? {
        sixtyFourBits ? peHeader.bindMemory(offset: 0, to: CINTEROP_IMAGE_NT_HEADERS64.self).pointer(to: \.OptionalHeader) : nil
    }

    public var dataDirectories: UnsafeBufferPointer<CINTEROP_IMAGE_DATA_DIRECTORY> {
        let array = sixtyFourBits
            ? peHeader.bindMemory(offset: 0, to: CINTEROP_IMAGE_NT_HEADERS64.self).pointer(to: \.OptionalHeader.DataDirectory)!
            : peHeader.bindMemory(offset: 0, to: CINTEROP_IMAGE_NT_HEADERS32.self).pointer(to: \.OptionalHeader.DataDirectory)!
        let first = UnsafeRawPointer(array).bindMemory(to: CINTEROP_IMAGE_DATA_DIRECTORY.self, capacity: Int(CINTEROP_IMAGE_NUMBEROF_DIRECTORY_ENTRIES))
        return UnsafeBufferPointer(start: first, count: Int(CINTEROP_IMAGE_NUMBEROF_DIRECTORY_ENTRIES))
    }

    public let sections: [Section]

    init(file: UnsafeRawBufferPointer) throws {
        self.file = file
        self.dosHeader = file.bindMemory(offset: 0, to: CINTEROP_IMAGE_DOS_HEADER.self)
        guard dosHeader.pointee.e_magic == CINTEROP_IMAGE_DOS_SIGNATURE else { throw InvalidFormatError.dosHeader }

        peHeader = file.sub(offset: Int(dosHeader.pointee.e_lfanew))
        var peHeaderRemainder = peHeader

        let peHeaderSignature = peHeaderRemainder.consume(type: UInt32.self).pointee
        guard peHeaderSignature == CINTEROP_IMAGE_NT_SIGNATURE else { throw InvalidFormatError.ntHeader }

        let fileHeader = peHeaderRemainder.consume(type: CINTEROP_IMAGE_FILE_HEADER.self)

        let optionalHeaderMagic = peHeaderRemainder.bindMemory(offset: 0, to: UInt16.self).pointee
        if optionalHeaderMagic == CINTEROP_IMAGE_NT_OPTIONAL_HDR32_MAGIC {
            let optionalHeader = peHeaderRemainder.consume(type: CINTEROP_IMAGE_OPTIONAL_HEADER32.self)
            guard optionalHeader.pointee.NumberOfRvaAndSizes == 16 else {
                throw InvalidFormatError.ntHeader
            }
        }
        else if optionalHeaderMagic == CINTEROP_IMAGE_NT_OPTIONAL_HDR64_MAGIC {
            let optionalHeader = peHeaderRemainder.consume(type: CINTEROP_IMAGE_OPTIONAL_HEADER64.self)
            guard optionalHeader.pointee.NumberOfRvaAndSizes == 16 else {
                throw InvalidFormatError.ntHeader
            }
        }
        else {
            throw InvalidFormatError.ntHeader
        }

        let sectionHeaders = peHeaderRemainder.consume(type: CINTEROP_IMAGE_SECTION_HEADER.self, count: Int(fileHeader.pointee.NumberOfSections))

        sections = (0 ..< sectionHeaders.count).map { sectionIndex in 
            let sectionHeader = sectionHeaders.baseAddress!.advanced(by: sectionIndex)
            let sectionData = file.sub(offset: Int(sectionHeader.pointee.PointerToRawData), count: Int(sectionHeader.pointee.SizeOfRawData))
            return Section(header: sectionHeader, data: sectionData)
        }
    }

    func resolve(virtualAddress: UInt32, size: UInt32) -> UnsafeRawBufferPointer {
        let section = sections.first { $0.contains(virtualAddress: virtualAddress) }!
        return section.resolve(virtualAddress: virtualAddress, size: size)
    }

    func resolve(_ dataDictionary: CINTEROP_IMAGE_DATA_DIRECTORY) -> UnsafeRawBufferPointer {
        resolve(virtualAddress: dataDictionary.VirtualAddress, size: dataDictionary.Size)
    }
}

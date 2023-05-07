extension PE {
    struct View {
        let file: UnsafeRawBufferPointer

        public let dosHeader: UnsafePointer<ImageDOSHeader>
        let peHeader: UnsafeRawBufferPointer

        var ntHeaders_maybe32: UnsafePointer<ImageNTHeaders32> {
            peHeader.bindMemory(offset: 0, to: ImageNTHeaders32.self)
        }

        public var fileHeader: UnsafePointer<ImageFileHeader> {
            ntHeaders_maybe32.pointer(to: \.fileHeader)!
        }

        public var sixtyFourBits: Bool { ntHeaders_maybe32.pointee.optionalHeader.magic == 0x20B }
        public var ntHeaders32: UnsafePointer<ImageNTHeaders32>? {
            sixtyFourBits ? nil : ntHeaders_maybe32
        }
        public var ntHeaders64: UnsafePointer<ImageNTHeaders64>? {
            sixtyFourBits ? peHeader.bindMemory(offset: 0, to: ImageNTHeaders64.self) : nil
        }

        public var ntOptionalHeaders32: UnsafePointer<ImageOptionalHeader32>? {
            sixtyFourBits ? nil : ntHeaders_maybe32.pointer(to: \.optionalHeader)
        }
        public var ntOptionalHeaders64: UnsafePointer<ImageOptionalHeader64>? {
            sixtyFourBits ? peHeader.bindMemory(offset: 0, to: ImageNTHeaders64.self).pointer(to: \.optionalHeader) : nil
        }

        public var dataDirectories: UnsafeBufferPointer<ImageDataDirectory> {
            let first = sixtyFourBits
                ? peHeader.bindMemory(offset: 0, to: ImageNTHeaders64.self).pointer(to: \.optionalHeader.dataDirectory_0)!
                : peHeader.bindMemory(offset: 0, to: ImageNTHeaders32.self).pointer(to: \.optionalHeader.dataDirectory_0)!
            return UnsafeBufferPointer(start: first, count: 16)
        }

        public let sections: [SectionView]

        init(file: UnsafeRawBufferPointer) throws {
            self.file = file
            self.dosHeader = file.bindMemory(offset: 0, to: ImageDOSHeader.self)
            guard dosHeader.pointee.e_signature == 0x5A4D else { throw InvalidFormatError.invalidDOSHeader } // IMAGE_DOS_SIGNATURE

            peHeader = file.sub(offset: Int(dosHeader.pointee.e_lfanew))
            var peHeaderRemainder = peHeader

            let peHeaderSignature = peHeaderRemainder.consume(type: UInt32.self).pointee
            guard peHeaderSignature == 0x00004550 else { throw InvalidFormatError.invalidNTHeader } // 'PE\0\0'

            let fileHeader = peHeaderRemainder.consume(type: ImageFileHeader.self)

            let optionalHeaderMagic = peHeaderRemainder.bindMemory(offset: 0, to: UInt16.self).pointee
            if optionalHeaderMagic == 0x10B { // PE32
                let optionalHeader = peHeaderRemainder.consume(type: ImageOptionalHeader32.self)
                guard optionalHeader.pointee.numberOfRvaAndSizes == 16 else {
                    throw InvalidFormatError.invalidNTHeader
                }
            }
            else if optionalHeaderMagic == 0x20B { // PE32+
                let optionalHeader = peHeaderRemainder.consume(type: ImageOptionalHeader64.self)
                guard optionalHeader.pointee.numberOfRvaAndSizes == 16 else {
                    throw InvalidFormatError.invalidNTHeader
                }
            }
            else {
                throw InvalidFormatError.invalidNTHeader
            }

            let sectionHeaders = peHeaderRemainder.consume(type: ImageSectionHeader.self, count: Int(fileHeader.pointee.numberOfSections))

            sections = (0 ..< sectionHeaders.count).map { sectionIndex in 
                let sectionHeader = sectionHeaders.baseAddress!.advanced(by: sectionIndex)
                let sectionData = file.sub(offset: Int(sectionHeader.pointee.pointerToRawData), count: Int(sectionHeader.pointee.sizeOfRawData))
                let sectionView = SectionView(header: sectionHeader, data: sectionData)
                return sectionView
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
}

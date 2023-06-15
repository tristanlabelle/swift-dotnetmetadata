extension PE {
    public struct SectionView {
        let header: UnsafePointer<ImageSectionHeader>
        let data: UnsafeRawBufferPointer

        var name: String {
            let chars = header.asRawBuffer().bindMemory(offset: 0, to: UInt8.self, count: 8)
            return String(bytes: chars.prefix { $0 != 0 }, encoding: .utf8)!
        }

        func contains(virtualAddress: UInt32) -> Bool {
            virtualAddress >= header.pointee.virtualAddress && virtualAddress < header.pointee.virtualAddress + header.pointee.virtualSize
        }

        func resolve(virtualAddress: UInt32, size: UInt32) -> UnsafeRawBufferPointer {
            precondition(self.contains(virtualAddress: virtualAddress))
            return data.sub(offset: Int(virtualAddress - header.pointee.virtualAddress), count: Int(size))
        }
    }
}
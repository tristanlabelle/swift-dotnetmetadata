extension PE {
    public struct SectionView {
        let header: UnsafePointer<ImageSectionHeader>
        let data: UnsafeRawBufferPointer

        func contains(virtualAddress: UInt32) -> Bool {
            virtualAddress >= header.pointee.virtualAddress && virtualAddress < header.pointee.virtualAddress + header.pointee.virtualSize
        }

        func resolve(virtualAddress: UInt32, size: UInt32) -> UnsafeRawBufferPointer {
            precondition(self.contains(virtualAddress: virtualAddress))
            return data.sub(offset: Int(virtualAddress - header.pointee.virtualAddress), count: Int(size))
        }
    }
}
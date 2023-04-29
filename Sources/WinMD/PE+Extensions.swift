extension PE.ImageSectionHeader {
    func getRawData(file: UnsafeRawBufferPointer) -> UnsafeRawBufferPointer {
        UnsafeRawBufferPointer(rebasing: file[Int(self.PointerToRawData) ..< Int(self.PointerToRawData + self.SizeOfRawData)])
    }

    func toFileOffset(rva: UInt32) -> Int {
        Int(rva - self.VirtualAddress + self.PointerToRawData)
    }
}

extension UnsafeBufferPointer where Element == PE.ImageSectionHeader {
    func find(rva: UInt32) -> UnsafePointer<Element>? {
        for i in 0 ..< count {
            if rva >= self[i].VirtualAddress && rva < self[i].VirtualAddress + self[i].VirtualSize {
                return self.baseAddress! + i
            }
        }
        return nil
    }
}

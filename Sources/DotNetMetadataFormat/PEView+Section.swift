import CInterop

extension PEView {
    public struct Section {
        let header: UnsafePointer<CINTEROP_IMAGE_SECTION_HEADER>
        let data: UnsafeRawBufferPointer

        var name: String {
            let chars = header.asRawBuffer().bindMemory(offset: 0, to: UInt8.self, count: 8)
            return String(bytes: chars.prefix { $0 != 0 }, encoding: .utf8)!
        }

        func contains(virtualAddress: UInt32) -> Bool {
            virtualAddress >= header.pointee.VirtualAddress && virtualAddress < header.pointee.VirtualAddress + header.pointee.Misc.VirtualSize
        }

        func resolve(virtualAddress: UInt32, size: UInt32) -> UnsafeRawBufferPointer {
            precondition(self.contains(virtualAddress: virtualAddress))
            return data.sub(offset: Int(virtualAddress - header.pointee.VirtualAddress), count: Int(size))
        }
    }
}
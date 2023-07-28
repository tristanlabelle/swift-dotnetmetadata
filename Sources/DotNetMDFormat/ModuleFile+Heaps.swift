import struct Foundation.UUID

extension ModuleFile {
    /// "namespace" for moduleFile.heaps.xxx syntax
    public struct Heaps {
        public let string: StringHeap
        public let guid: GuidHeap
        public let blob: BlobHeap
        
        public func resolve(_ offset: StringHeap.Offset) -> String {
            string.resolve(at: offset.value)
        }
        
        public func resolve(_ offset: GuidHeap.Offset) -> UUID {
            guid.resolve(at: offset.value)
        }
        
        public func resolve(_ offset: BlobHeap.Offset) -> UnsafeRawBufferPointer {
            blob.resolve(at: offset.value)
        }
    }
}
import struct Foundation.UUID

extension Database {
    /// "namespace" for database.heaps.xxx syntax
    public struct Heaps {
        public let string: StringHeap
        public let guid: GuidHeap
        public let blob: BlobHeap
        
        public func resolve(_ offset: HeapOffset<StringHeap>) -> String {
            string.resolve(at: offset.value)
        }
        
        public func resolve(_ offset: HeapOffset<GuidHeap>) -> UUID {
            guid.resolve(at: offset.value)
        }
        
        public func resolve(_ offset: HeapOffset<BlobHeap>) -> UnsafeRawBufferPointer {
            blob.resolve(at: offset.value)
        }
    }
}
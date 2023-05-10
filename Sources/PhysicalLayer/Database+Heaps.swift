import struct Foundation.UUID

extension Database {
    public class Heaps {
        public let string: StringHeap
        public let guid: GuidHeap
        public let blob: BlobHeap

        init(string: StringHeap, guid: GuidHeap, blob: BlobHeap) {
            self.string = string
            self.guid = guid
            self.blob = blob
        }
        
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
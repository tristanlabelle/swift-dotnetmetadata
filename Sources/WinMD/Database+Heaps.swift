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
        
        public func resolve(_ entry: HeapEntry<StringHeap>) -> String {
            string.resolve(at: entry.offset)
        }
        
        public func resolve(_ entry: HeapEntry<GuidHeap>) -> UUID {
            guid.resolve(at: entry.offset)
        }
        
        public func resolve(_ entry: HeapEntry<BlobHeap>) -> UnsafeRawBufferPointer {
            blob.resolve(at: entry.offset)
        }
    }
}
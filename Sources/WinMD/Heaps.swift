import Foundation

class StringHeap {
    var buffer: UnsafeRawBufferPointer

    init(buffer: UnsafeRawBufferPointer) {
        self.buffer = buffer
    }

    func at(offset: Int) -> String {
        fatalError()
    }
}

struct StringRef {
    var heap: StringHeap
    var offset: Int

    var value: String { heap.at(offset: offset) }
}

class GuidHeap {
    var buffer: UnsafeRawBufferPointer

    init(buffer: UnsafeRawBufferPointer) {
        self.buffer = buffer
    }

    func at(offset: Int) -> UUID {
        fatalError()
    }
}

struct GuidRef {
    var heap: GuidHeap
    var offset: Int
    var value: UUID { heap.at(offset: offset) }
}

class BlobHeap {
    var buffer: UnsafeRawBufferPointer

    init(buffer: UnsafeRawBufferPointer) {
        self.buffer = buffer
    }
}

struct BlobRef {
    var BlobHeap: BlobHeap
    var offset: Int
}
import Foundation

public class StringHeap {
    var buffer: UnsafeRawBufferPointer

    init(buffer: UnsafeRawBufferPointer) {
        self.buffer = buffer
    }

    func ref(offset: Int) -> StringRef {
        StringRef(heap: self, offset: offset)
    }

    func at(offset: Int) -> String {
        String(bytes: buffer.sub(offset: offset).prefix { $0 != 0 }, encoding: .utf8)!
    }
}

public struct StringRef {
    var heap: StringHeap
    var offset: Int

    var value: String { heap.at(offset: offset) }
}

public class GuidHeap {
    var buffer: UnsafeRawBufferPointer

    init(buffer: UnsafeRawBufferPointer) {
        self.buffer = buffer
    }

    func ref(offset: Int) -> GuidRef {
        GuidRef(heap: self, offset: offset)
    }

    func at(offset: Int) -> UUID {
        fatalError()
    }
}

public struct GuidRef {
    var heap: GuidHeap
    var offset: Int
    var value: UUID { heap.at(offset: offset) }
}

public class BlobHeap {
    var buffer: UnsafeRawBufferPointer

    init(buffer: UnsafeRawBufferPointer) {
        self.buffer = buffer
    }

    func ref(offset: Int) -> BlobRef {
        BlobRef(heap: self, offset: offset)
    }
}

public struct BlobRef {
    var heap: BlobHeap
    var offset: Int
}
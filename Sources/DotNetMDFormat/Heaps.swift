import struct Foundation.UUID

public protocol Heap {
    associatedtype Value

    func resolve(at: UInt32) -> Value
}

public class StringHeap: Heap {
    public typealias Value = String

    private let buffer: UnsafeRawBufferPointer
    private var cache: [UInt32: String] = [:]

    init(buffer: UnsafeRawBufferPointer) {
        self.buffer = buffer
    }

    public func resolve(at offset: UInt32) -> String {
        if let existing = cache[offset] { return existing }
        let result = String(bytes: buffer.sub(offset: Int(offset)).prefix { $0 != 0 }, encoding: .utf8)!
        cache[offset] = result
        return result
    }
}

public class GuidHeap: Heap {
    public typealias Value = UUID

    var buffer: UnsafeRawBufferPointer

    init(buffer: UnsafeRawBufferPointer) {
        self.buffer = buffer
    }

    public func resolve(at offset: UInt32) -> UUID {
        buffer.bindMemory(offset: Int(offset), to: UUID.self).pointee
    }
}

public class BlobHeap: Heap {
    public typealias Value = UnsafeRawBufferPointer

    var buffer: UnsafeRawBufferPointer

    init(buffer: UnsafeRawBufferPointer) {
        self.buffer = buffer
    }

    public func resolve(at offset: UInt32) -> UnsafeRawBufferPointer {
        var remainder = buffer.sub(offset: Int(offset))
        let size = consumeCompressedUInt(buffer: &remainder)
        return remainder.sub(offset: 0, count: Int(size))
    }
}

public struct HeapOffset<Type> where Type: Heap {
    public var value: UInt32

    public init(_ value: UInt32) {
        self.value = value
    }

    public func resolve(_ heap: Type) -> Type.Value {
        heap.resolve(at: value)
    }
}
import Foundation

public protocol Heap {
    associatedtype Value

    func resolve(at: UInt32) -> Value
}

public class StringHeap: Heap {
    public typealias Value = String

    var buffer: UnsafeRawBufferPointer

    init(buffer: UnsafeRawBufferPointer) {
        self.buffer = buffer
    }

    public func resolve(at offset: UInt32) -> String {
        String(bytes: buffer.sub(offset: Int(offset)).prefix { $0 != 0 }, encoding: .utf8)!
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
        fatalError()
    }
}

public struct HeapEntry<Type> where Type: Heap {
    public var offset: UInt32

    public init(_ offset: UInt32) {
        self.offset = offset
    }

    public func resolve(_ heap: Type) -> Type.Value {
        heap.resolve(at: offset)
    }
}
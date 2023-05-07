extension UnsafeRawBufferPointer {
    func sub(offset: Int) -> UnsafeRawBufferPointer {
        UnsafeRawBufferPointer(rebasing: self[offset...])
    }

    func sub(offset: Int, count: Int) -> UnsafeRawBufferPointer {
        UnsafeRawBufferPointer(rebasing: self[offset ..< (offset + count)])
    }

    func bindMemory<T>(offset: Int, to: T.Type) -> UnsafePointer<T> {
        sub(offset: offset).bindMemory(to: T.self).baseAddress!
    }
    
    func bindMemory<T>(offset: Int, to: T.Type, count: Int) -> UnsafeBufferPointer<T> {
        let rebased = UnsafeRawBufferPointer(rebasing: self[offset...])
        let bound = rebased.bindMemory(to: T.self)
        return UnsafeBufferPointer<T>(rebasing: bound[0 ..< count])
    }
    
    @discardableResult mutating func consume(count: Int) -> UnsafeRawBufferPointer {
        let result = self.sub(offset: 0, count: count)
        self = self.sub(offset: count)
        return result
    }

    @discardableResult mutating func consume<T>(type: T.Type) -> UnsafePointer<T> {
        let result = bindMemory(offset: 0, to: type)
        self = self.sub(offset: MemoryLayout<T>.stride)
        return result
    }
    
    @discardableResult mutating func consume<T>(type: T.Type, count: Int) -> UnsafeBufferPointer<T> {
        let result = bindMemory(offset: 0, to: type, count: count)
        self = self.sub(offset: MemoryLayout<T>.stride * count)
        return result
    }
    
    @discardableResult mutating func consumeDwordPaddedUTF8String() -> String {
        let length = self.firstIndex(of: 0)!
        let result = String(bytes: self.sub(offset: 0, count: length), encoding: .utf8)!
        self = sub(offset: (length + 4) & ~0x3)
        return result
    }
}

extension UnsafePointer {
    func asRawBuffer() -> UnsafeRawBufferPointer {
        UnsafeRawBufferPointer(start: self, count: MemoryLayout<Pointee>.stride)
    }
}
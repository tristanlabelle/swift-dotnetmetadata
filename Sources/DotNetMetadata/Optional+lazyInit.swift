extension Optional {
    internal func unwrapOrThrow<E: Error>(_ error: @autoclosure () -> E) throws -> Wrapped {
        guard let value = self else { throw error() }
        return value
    }

    internal mutating func lazyInit(_ lazyInit: () throws -> Wrapped) rethrows -> Wrapped {
        if let value = self { return value }
        let value = try lazyInit()
        self = value
        return value
    }
}
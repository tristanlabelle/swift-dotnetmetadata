internal func lazyInit<T>(storage: inout T?, initializer: () throws -> T) rethrows -> T {
    if let existing = storage { return existing }
    let new = try initializer()
    storage = new
    return new
}
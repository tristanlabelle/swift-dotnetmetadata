public protocol AttributeType {
    associatedtype Value = Self

    static var namespace: String? { get }
    static var name: String { get }
    static var validOn: AttributeTargets { get }
    static var allowMultiple: Bool { get }
    static var inherited: Bool { get }

    static func decode(_ attribute: Attribute) throws -> Value
}

extension Attribute {
    public func hasType<T: AttributeType>(_ type: T.Type) throws -> Bool {
        let actualType = try self.type
        return actualType.namespace == type.namespace && actualType.name == type.name
    }

    public func decode<T: AttributeType>(as type: T.Type) throws -> T.Value {
        try type.decode(self)
    }
}
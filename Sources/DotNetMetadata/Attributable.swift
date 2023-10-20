public protocol Attributable: AnyObject {
    var attributeTarget: AttributeTargets { get }
    var attributes: [Attribute] { get }
}

extension Attributable {
    public func firstAttribute(namespace: String, name: String) throws -> Attribute? {
        try attributes.first { try $0.type.namespace == namespace && $0.type.name == name }
    }

    public func hasAttribute(namespace: String, name: String) throws -> Bool {
        try firstAttribute(namespace: namespace, name: name) != nil
    }

    public func hasAttribute<T: AttributeType>(_ type: T.Type) throws -> Bool {
        try attributes.contains { try $0.hasType(T.self) }
    }

    public func firstAttribute<T: AttributeType>(_ type: T.Type) throws -> T.Value? {
        guard let attribute = try attributes.first(where: { try $0.hasType(T.self) }) else { return nil }
        return try attribute.decode(as: T.self)
    }

    public func getAttributes<T: AttributeType>(_ type: T.Type) throws -> [T.Value] {
        var result = [T.Value]()
        for attribute in attributes {
            guard try attribute.hasType(T.self) else { continue }
            result.append(try attribute.decode(as: T.self))
        }
        return result
    }
}

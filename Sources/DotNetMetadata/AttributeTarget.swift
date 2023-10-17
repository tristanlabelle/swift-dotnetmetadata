public protocol Attributable {
    var attributes: [Attribute] { get }
}

extension Attributable {
    public func firstAttribute(namespace: String, name: String) throws -> Attribute? {
        try attributes.first { try $0.type.namespace == namespace && $0.type.name == name }
    }

    public func hasAttribute(namespace: String, name: String) throws -> Bool {
        try firstAttribute(namespace: namespace, name: name) != nil
    }
}
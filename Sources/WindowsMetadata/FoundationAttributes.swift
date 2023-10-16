import DotNetMetadata

public enum FoundationAttributes {
    public static let namespace = "Windows.Foundation.Metadata"

    public static func isDefaultInterface(baseInterface: BaseInterface) throws -> Bool {
        try baseInterface.hasAttribute(namespace: namespace, name: "DefaultAttribute")
    }

    public static func getDefaultInterface(class: ClassDefinition) throws -> BoundType? {
        try `class`.baseInterfaces.first {
            try isDefaultInterface(baseInterface: $0)
        }?.interface
    }

    public static func hasDefaultOverload(method: Method) throws -> Bool {
        try method.hasAttribute(namespace: namespace, name: "DefaultOverloadAttribute")
    }

    public static func getOverloadName(method: Method) throws -> String? {
        guard let attribute = try method.firstAttribute(namespace: namespace, name: "OverloadAttribute") else { return nil }
        guard try attribute.arguments.count == 1,
            case .constant(let constant) = try attribute.arguments[0],
            case .string(let name) = constant else {
            return nil // TODO: Throw?
        }
        return name
    }

    public static func getOverloadNameOrName(method: Method) throws -> String {
        try getOverloadName(method: method) ?? method.name
    }

    public static func hasNoException(method: Method) throws -> Bool {
        try method.hasAttribute(namespace: namespace, name: "NoExceptionAttribute")
    }

    public static func hasNoException(property: Property) throws -> Bool {
        try property.hasAttribute(namespace: namespace, name: "NoExceptionAttribute")
    }
}
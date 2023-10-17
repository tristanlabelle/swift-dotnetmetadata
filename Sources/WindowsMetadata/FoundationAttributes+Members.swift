import DotNetMetadata

// Attributes applying to members
extension FoundationAttributes {
    public static func hasProtected(_ member: Member) throws -> Bool {
        try member.hasAttribute(namespace: namespace, name: "ProtectedAttribute")
    }

    public static func hasInternal(_ member: Member) throws -> Bool {
        try member.hasAttribute(namespace: namespace, name: "InternalAttribute")
    }

    public static func hasDefaultOverload(_ method: Method) throws -> Bool {
        try method.hasAttribute(namespace: namespace, name: "DefaultOverloadAttribute")
    }

    public static func getOverloadName(_ method: Method) throws -> String? {
        guard let attribute = try method.firstAttribute(namespace: namespace, name: "OverloadAttribute") else { return nil }
        guard try attribute.arguments.count == 1,
            case .constant(let constant) = try attribute.arguments[0],
            case .string(let name) = constant else {
            return nil // TODO: Throw?
        }
        return name
    }

    public static func getOverloadNameOrName(_ method: Method) throws -> String {
        try getOverloadName(method) ?? method.name
    }

    public static func hasNoException(_ method: Method) throws -> Bool {
        try method.hasAttribute(namespace: namespace, name: "NoExceptionAttribute")
    }

    public static func hasNoException(_ property: Property) throws -> Bool {
        try property.hasAttribute(namespace: namespace, name: "NoExceptionAttribute")
    }
}
import DotNetMetadata

/// Identifies the method as an overload in a language that supports overloading.
public struct OverloadAttribute: AttributeType {
    public var methodName: String

    public init(_ methodName: String) {
        self.methodName = methodName
    }

    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "OverloadAttribute" }
    public static var validOn: AttributeTargets { .method }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Self {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .string(let name) = constant else { throw InvalidMetadataError.attributeArguments }
        return .init(name)
    }
}
import DotNetMetadata

/// Identifies the method as an overload in a language that supports overloading.
public enum OverloadAttribute: AttributeType {
    public static var namespace: String { "Windows.Foundation.Metadata" }
    public static var name: String { "OverloadAttribute" }
    public static var validOn: AttributeTargets { .method }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> String {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .string(let name) = constant else { throw InvalidMetadataError.attributeArguments }
        return name
    }
}
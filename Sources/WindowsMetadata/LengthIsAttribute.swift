import DotNetMetadata

/// Indicates the number of array elements.
public enum LengthIsAttribute: AttributeType {
    public static var namespace: String { "Windows.Foundation.Metadata" }
    public static var name: String { "LengthIsAttribute" }
    public static var validOn: AttributeTargets { .param }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Int32 {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .int32(let value) = constant else { throw InvalidMetadataError.attributeArguments }
        return value
    }
}
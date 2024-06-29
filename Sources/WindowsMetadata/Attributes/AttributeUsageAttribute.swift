import DotNetMetadata

/// Windows Runtime-specific variant of [AttributeUsage].
public struct AttributeUsageAttribute: AttributeType {
    public var validOn: AttributeTargets

    public init(_ validOn: AttributeTargets) {
        self.validOn = validOn
    }

    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "AttributeUsageAttribute" }
    public static var validOn: AttributeTargets { .class }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> AttributeUsageAttribute {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let validOnConstant) = arguments[1],
            case .int32(let validOnValue) = validOnConstant else { throw InvalidMetadataError.attributeArguments }
        return AttributeUsageAttribute(
            AttributeTargets(rawValue: validOnValue))
    }
}

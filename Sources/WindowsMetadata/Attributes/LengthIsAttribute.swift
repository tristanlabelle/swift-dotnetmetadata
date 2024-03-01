import DotNetMetadata

/// Indicates the number of array elements.
public struct LengthIsAttribute: AttributeType {
    public var paramIndex: Int32

    public init(_ paramIndex: Int32) {
        self.paramIndex = paramIndex
    }

    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "LengthIsAttribute" }
    public static var validOn: AttributeTargets { .parameter }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Self {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .int32(let value) = constant else { throw InvalidMetadataError.attributeArguments }
        return .init(value)
    }
}
public enum GuidAttribute: AttributeType {
    public static var namespace: String? { "System.Runtime.InteropServices" }
    public static var name: String { "GuidAttribute" }
    public static var validOn: AttributeTargets { .assembly | .allTypes }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> String {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .string(let value) = constant else { throw InvalidMetadataError.attributeArguments }
        return value
    }
}

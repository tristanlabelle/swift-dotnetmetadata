public enum ComVisibleAttribute: AttributeType {
    public static var namespace: String? { "System.Runtime.InteropServices" }
    public static var name: String { "ComVisibleAttribute" }
    public static var validOn: AttributeTargets { .assembly | .allTypes | .method | .property | .field }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { false }

    public static func decode(_ attribute: Attribute) throws -> Bool {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .boolean(let value) = constant else { throw InvalidMetadataError.attributeArguments }

        return value
    }
}

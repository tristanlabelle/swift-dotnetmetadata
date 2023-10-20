public struct AttributeUsageAttribute: AttributeType {
    public var validOn: AttributeTargets
    public var allowMultiple: Bool
    public var inherited: Bool

    public init(validOn: AttributeTargets, allowMultiple: Bool, inherited: Bool) {
        self.validOn = validOn
        self.allowMultiple = allowMultiple
        self.inherited = inherited
    }

    public static var namespace: String { "System" }
    public static var name: String { "AttributeUsageAttribute" }
    public static var validOn: AttributeTargets { .class }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> AttributeUsageAttribute {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let validOnConstant) = arguments[1],
            case .int32(let validOnValue) = validOnConstant else { throw InvalidMetadataError.attributeArguments }

        var inherited: Bool? = nil
        var allowMultiple: Bool? = nil
        for namedArg in try attribute.namedArguments {
            guard case .property(let property) = namedArg.target,
                case .constant(let valueConstant) = namedArg.value,
                case .boolean(let value) = valueConstant else {
                throw InvalidMetadataError.attributeArguments
            }

            switch property.name {
                case "Inherited": inherited = value
                case "AllowMultiple": allowMultiple = value
                default: throw InvalidMetadataError.attributeArguments
            }
        }

        return AttributeUsageAttribute(
            validOn: AttributeTargets(rawValue: validOnValue),
            allowMultiple: allowMultiple ?? false,
            inherited: inherited ?? true)
    }
}

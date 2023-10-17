/// Provides methods for retrieving data from well-known attributes from the System namespaces.
public enum SystemAttributes {
    public static func getAttributeUsage(_ attributeClass: ClassDefinition) throws -> AttributeUsage? {
        guard let attribute = try attributeClass.firstAttribute(namespace: "System", name: "AttributeUsageAttribute") else {
            return nil
        }

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

        return AttributeUsage(
            validOn: Attributables(rawValue: validOnValue),
            allowMultiple: allowMultiple ?? false,
            inherited: inherited ?? true)
    }

    public static func hasComImport(_ type: TypeDefinition) throws -> Bool {
        return try type.hasAttribute(namespace: "System.Runtime.InteropServices", name: "ComVisibleAttribute")
    }

    public static func getComVisible(_ type: TypeDefinition) throws -> Bool? {
        guard let attribute = try type.firstAttribute(namespace: "System.Runtime.InteropServices", name: "ComVisibleAttribute") else {
            return nil
        }

        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .boolean(let value) = constant else {
            throw InvalidMetadataError.attributeArguments
        }

        return value
    }
}
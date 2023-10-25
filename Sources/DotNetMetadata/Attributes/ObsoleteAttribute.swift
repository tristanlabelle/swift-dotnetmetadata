public struct ObsoleteAttribute: AttributeType {
    public var message: String? = nil
    public var isError: Bool = false
    public var diagnosticId: String? = nil
    public var urlFormat: String? = nil

    public init() {}

    public init(message: String?, isError: Bool, diagnosticId: String? = nil, urlFormat: String? = nil) {
        self.message = message
        self.isError = isError
        self.diagnosticId = diagnosticId
        self.urlFormat = urlFormat
    }

    public static var namespace: String? { "System" }
    public static var name: String { "ObsoleteAttribute" }
    public static var validOn: AttributeTargets { .allTypes | .allMembers }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { false }

    public static func decode(_ attribute: Attribute) throws -> ObsoleteAttribute {
        let arguments = try attribute.arguments

        guard arguments.count <= 2 else { throw InvalidMetadataError.attributeArguments }

        var result = ObsoleteAttribute()
        if arguments.count >= 1 {
            guard case .constant(let messageConstant) = arguments[0],
                case .string(let message) = messageConstant else { throw InvalidMetadataError.attributeArguments }
            result.message = message
        }
        if arguments.count == 2 {
            guard case .constant(let isErrorConstant) = arguments[1],
                case .boolean(let isError) = isErrorConstant else { throw InvalidMetadataError.attributeArguments }
            result.isError = isError
        }

        for namedArg in try attribute.namedArguments {
            guard case .property(let property) = namedArg.target,
                case .constant(let valueConstant) = namedArg.value,
                case .string(let value) = valueConstant else {
                throw InvalidMetadataError.attributeArguments
            }

            switch property.name {
                case "DiagnosticId": result.diagnosticId = value
                case "UrlFormat": result.urlFormat = value
                default: throw InvalidMetadataError.attributeArguments
            }
        }

        return result
    }
}

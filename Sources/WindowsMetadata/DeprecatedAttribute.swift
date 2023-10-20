import DotNetMetadata

public struct DeprecatedAttribute: AttributeType {
    public enum Kind: Int32, Hashable {
        /// Compilers and other tools should treat the entity as deprecated.
        /// This is the default.
        case deprecate = 0
        /// Compilers and other tools should treat the entity as removed.
        case remove = 1
    }

    public var message: String
    public var kind: Kind
    public var applicability: VersionApplicability

    public init(message: String, kind: Kind, applicability: VersionApplicability) {
        self.message = message
        self.kind = kind
        self.applicability = applicability
    }

    public static var namespace: String { "Windows.Foundation.Metadata" }
    public static var name: String { "DeprecatedAttribute" }
    public static var validOn: AttributeTargets { .allTypes | .allMembers }
    public static var allowMultiple: Bool { true }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> DeprecatedAttribute {
        let arguments = try attribute.arguments
        guard arguments.count >= 3 else { throw InvalidMetadataError.attributeArguments }

        guard case .constant(let messageConstant) = arguments[0],
            case .string(let message) = messageConstant,
            case .constant(let typeConstant) = arguments[1],
            case .int32(let typeValue) = typeConstant,
            let kind = Kind(rawValue: typeValue) else { throw InvalidMetadataError.attributeArguments }

        return DeprecatedAttribute(
            message: message, kind: kind,
            applicability: try VersionApplicability.decode(arguments[2...]))
    }
}
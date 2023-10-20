import DotNetMetadata

/// Indicates how a programming element is composed.
public struct ComposableAttribute: AttributeType {
    public enum Kind: Int32, Hashable {
        /// Indicates that access to the programming element is limited to other elements
        /// in the containing class or types derived from the containing class.
        case protected = 1
        /// Indicates that access to the programming element is not restricted.
        case `public` = 2
    }

    public var factory: InterfaceDefinition
    public var kind: Kind
    public var applicability: VersionApplicability

    public init(factory: InterfaceDefinition, kind: Kind, applicability: VersionApplicability) {
        self.factory = factory
        self.kind = kind
        self.applicability = applicability
    }

    public static var namespace: String { "Windows.Foundation.Metadata" }
    public static var name: String { "ComposableAttribute" }
    public static var validOn: AttributeTargets { .class }
    public static var allowMultiple: Bool { true }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> ComposableAttribute {
        let arguments = try attribute.arguments
        guard arguments.count >= 3 else { throw InvalidMetadataError.attributeArguments }

        guard case .type(let factoryDefinition) = arguments[0],
            let factory = factoryDefinition as? InterfaceDefinition,
            case .constant(let typeConstant) = arguments[1],
            case .int32(let typeValue) = typeConstant,
            let kind = Kind(rawValue: typeValue) else { throw InvalidMetadataError.attributeArguments }

        return ComposableAttribute(
            factory: factory, kind: kind,
            applicability: try VersionApplicability.decode(arguments[2...]))
    }
}

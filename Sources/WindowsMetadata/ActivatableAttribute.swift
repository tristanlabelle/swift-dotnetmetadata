import DotNetMetadata

/// Indicates that the class is an activatable runtime class.
public struct ActivatableAttribute: AttributeType {
    public var factory: InterfaceDefinition? = nil
    public var applicability: VersionApplicability

    public init(factory: InterfaceDefinition? = nil, applicability: VersionApplicability) {
        self.factory = factory
        self.applicability = applicability
    }

    public static var namespace: String { "Windows.Foundation.Metadata" }
    public static var name: String { "ActivatableAttribute" }
    public static var validOn: AttributeTargets { .class }
    public static var allowMultiple: Bool { true }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> ActivatableAttribute {
        let arguments = try attribute.arguments
        guard arguments.count >= 1 else { throw InvalidMetadataError.attributeArguments }

        if case .type(let factoryDefinition) = arguments[0] {
            guard let factory = factoryDefinition as? InterfaceDefinition else { throw InvalidMetadataError.attributeArguments }
            return ActivatableAttribute(
                factory: factory,
                applicability: try VersionApplicability.decode(arguments[1...]))
        }
        else {
            return ActivatableAttribute(
                applicability: try VersionApplicability.decode(arguments[...]))
        }
    }
}
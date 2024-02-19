import DotNetMetadata

/// Indicates an interface that contains only static methods.
public struct StaticAttribute: AttributeType {
    public var interface: InterfaceDefinition
    public var applicability: VersionApplicability

    public init(interface: InterfaceDefinition, applicability: VersionApplicability) {
        self.interface = interface
        self.applicability = applicability
    }

    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "StaticAttribute" }
    public static var validOn: AttributeTargets { .class }
    public static var allowMultiple: Bool { true }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> StaticAttribute {
        let arguments = try attribute.arguments
        guard arguments.count >= 2 else { throw InvalidMetadataError.attributeArguments }
        guard case .type(let definition) = arguments[0],
            let interface = definition as? InterfaceDefinition else { throw InvalidMetadataError.attributeArguments }
        return StaticAttribute(
            interface: interface,
            applicability: try VersionApplicability.decode(arguments[1...]))
    }
}
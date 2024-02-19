import DotNetMetadata

public struct ExclusiveToAttribute: AttributeType {
    public var target: ClassDefinition

    public init(_ target: ClassDefinition) {
        self.target = target
    }

    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "ExclusiveToAttribute" }
    public static var validOn: AttributeTargets { .interface }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> ExclusiveToAttribute {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .type(let target) = arguments[0],
            let targetClass = target as? ClassDefinition else { throw InvalidMetadataError.attributeArguments }
        return .init(targetClass)
    }
}

import DotNetMetadata

/// Indicates the default interface for a runtime class.
public enum DefaultAttribute: AttributeType {
    public static var namespace: String { "Windows.Foundation.Metadata" }
    public static var name: String { "DefaultAttribute" }
    public static var validOn: AttributeTargets { .none } // No attribute target for interface implementations
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Void {}

    public static func getDefaultInterface(_ class: ClassDefinition) throws -> BoundType? {
        try `class`.baseInterfaces.first { try $0.hasAttribute(DefaultAttribute.self) }?.interface
    }
}
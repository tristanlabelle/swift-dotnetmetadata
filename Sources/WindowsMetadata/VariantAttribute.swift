import DotNetMetadata

/// Indicates that the item is an instance of a variant **IInspectable**.
/// Applies to method parameters, properties, and return values of types.
public enum VariantAttribute: AttributeType {
    public static var namespace: String { "Windows.Foundation.Metadata" }
    public static var name: String { "VariantAttribute" }
    public static var validOn: AttributeTargets { .property | .param }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Void {}
}
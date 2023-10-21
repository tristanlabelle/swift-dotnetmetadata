import DotNetMetadata

/// Indicates that a method is the default overload method.
/// This attribute must be used with OverloadAttribute.
public enum DefaultOverloadAttribute: AttributeType {
    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "DefaultOverloadAttribute" }
    public static var validOn: AttributeTargets { .method }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Void {}
}
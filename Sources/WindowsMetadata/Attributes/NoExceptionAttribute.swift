import DotNetMetadata

/// Indicates that the interface contains protected methods.
public struct NoExceptionAttribute: AttributeType {
    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "NoExceptionAttribute" }
    public static var validOn: AttributeTargets { .method | .property }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Self { .init() }
}
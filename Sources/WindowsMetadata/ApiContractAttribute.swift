import DotNetMetadata

/// Specifies that the type represents an API contract.
public enum ApiContractAttribute: AttributeType {
    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "ApiContractAttribute" }
    public static var validOn: AttributeTargets { .enum }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Void {}
}
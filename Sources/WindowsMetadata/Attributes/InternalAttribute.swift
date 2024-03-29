import DotNetMetadata

/// Indicates that the interface contains internal methods.
public struct InternalAttribute: AttributeType {
    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "InternalAttribute" }
    public static var validOn: AttributeTargets { .interfaceImpl } // No attribute target for interface implementations
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Self { .init() }
}
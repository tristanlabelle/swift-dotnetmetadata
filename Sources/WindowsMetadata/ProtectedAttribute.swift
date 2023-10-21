import DotNetMetadata

/// Indicates that the interface contains protected methods.
public enum ProtectedAttribute: AttributeType {
    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "ProtectedAttribute" }
    public static var validOn: AttributeTargets { .none } // No attribute target for interface implementations
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Void {}
}
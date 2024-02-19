import DotNetMetadata

/// Indicates that a type or member should be marked in metadata as experimental, 
/// and consequently may not be present in the final, released version of an SDK or library.
public struct ExperimentalAttribute: AttributeType {
    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "ExperimentalAttribute" }
    public static var validOn: AttributeTargets { .allTypes }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Self { .init() }
}
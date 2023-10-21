import DotNetMetadata

public enum DualApiPartitionAttribute: AttributeType {
    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "DualApiPartitionAttribute" }
    public static var validOn: AttributeTargets { .class }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Version {
        let namedArguments = try attribute.namedArguments
        if namedArguments.count == 0 { return Version(major: 0, minor: 0) }
        guard namedArguments.count <= 1,
            case .field(let field) = namedArguments[0].target,
            field.name == "version",
            case .constant(let versionConstant) = namedArguments[0].value,
            case .uint32(let versionValue) = versionConstant else { throw InvalidMetadataError.attributeArguments }
        return Version(unpacking: versionValue)
    }
}
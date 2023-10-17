import DotNetMetadata

public struct StaticInterface {
    public var type: TypeDefinition
    public var applicability: VersionApplicability

    public init(type: TypeDefinition, applicability: VersionApplicability) {
        self.type = type
        self.applicability = applicability
    }
}
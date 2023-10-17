import DotNetMetadata

public struct ActivatableData {
    public var type: InterfaceDefinition? = nil
    public var applicability: VersionApplicability

    public init(type: InterfaceDefinition? = nil, applicability: VersionApplicability) {
        self.type = type
        self.applicability = applicability
    }
}
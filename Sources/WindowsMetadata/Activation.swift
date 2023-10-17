import DotNetMetadata

public struct Activation {
    public var factory: InterfaceDefinition? = nil
    public var applicability: VersionApplicability

    public init(factory: InterfaceDefinition? = nil, applicability: VersionApplicability) {
        self.factory = factory
        self.applicability = applicability
    }
}
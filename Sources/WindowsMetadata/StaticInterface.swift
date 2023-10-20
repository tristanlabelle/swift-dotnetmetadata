import DotNetMetadata

public struct StaticInterface {
    public var interface: InterfaceDefinition
    public var applicability: VersionApplicability

    public init(interface: InterfaceDefinition, applicability: VersionApplicability) {
        self.interface = interface
        self.applicability = applicability
    }
}
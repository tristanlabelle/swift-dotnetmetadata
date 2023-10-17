import DotNetMetadata

public struct ActivatableData {
    public var type: InterfaceDefinition? = nil
    public var startVersion: StartVersion

    public init(type: InterfaceDefinition? = nil, startVersion: StartVersion) {
        self.type = type
        self.startVersion = startVersion
    }
}
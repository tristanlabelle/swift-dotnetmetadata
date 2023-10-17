import DotNetMetadata

public struct StaticInterface {
    public var type: TypeDefinition
    public var startVersion: StartVersion

    public init(type: TypeDefinition, startVersion: StartVersion) {
        self.type = type
        self.startVersion = startVersion
    }
}
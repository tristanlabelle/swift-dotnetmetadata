import DotNetMetadata

public struct ContractVersion {
    public enum Contract {
        case type(TypeDefinition)
        case name(String)
    }

    public var contract: Contract?
    public var version: Version

    public init(contract: Contract? = nil, version: Version) {
        self.contract = contract
        self.version = version
    }

    public init(contract: String, version: Version) {
        self.init(contract: .name(contract), version: version)
    }

    public init(contract: TypeDefinition, version: Version) {
        self.init(contract: .type(contract), version: version)
    }
}
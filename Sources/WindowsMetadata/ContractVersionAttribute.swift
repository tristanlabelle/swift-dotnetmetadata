import DotNetMetadata

public struct ContractVersionAttribute: AttributeType {
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

    public static var namespace: String { "Windows.Foundation.Metadata" }
    public static var name: String { "ContractVersionAttribute" }
    public static var validOn: AttributeTargets { .allTypes | .allMembers }
    public static var allowMultiple: Bool { true }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> ContractVersionAttribute {
        // Three possible constructors:
        // - ContractVersionAttribute(uint version)
        // - ContractVersionAttribute(Type contract, uint version)
        // - ContractVersionAttribute(string contract, uint version)
        let arguments = try attribute.arguments
        guard arguments.count == 1 || arguments.count == 2 else { throw InvalidMetadataError.attributeArguments }

        let contract: Contract?
        if arguments.count == 2 {
            switch arguments[0] {
                case .constant(let contractConstant):
                    guard case .string(let name) = contractConstant else { throw InvalidMetadataError.attributeArguments }
                    contract = .name(name)
                case .type(let definition):
                    contract = .type(definition)
                default:
                    throw InvalidMetadataError.attributeArguments
            }
        }
        else {
            contract = nil
        }

        guard case .constant(let versionConstant) = arguments.last!,
            case .uint32(let version) = versionConstant else { throw InvalidMetadataError.attributeArguments }

        return ContractVersionAttribute(contract: contract, version: .init(unpacking: version))
    }
}
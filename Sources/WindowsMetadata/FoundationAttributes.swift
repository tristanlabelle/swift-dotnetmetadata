import DotNetMetadata

/// Provides methods for retrieving data from well-known attributes from the Windows.Foundation.Metadata namespace.
public enum FoundationAttributes {
    public static let namespace = "Windows.Foundation.Metadata"

    public static func hasVariant(_ type: TypeDefinition) throws -> Bool {
        try type.hasAttribute(namespace: namespace, name: "HasVariantAttribute")
    }

    public static func hasAllowMultiple(_ type: ClassDefinition) throws -> Bool {
        try type.hasAttribute(namespace: namespace, name: "AllowMultipleAttribute")
    }

    public static func hasExperimental(_ type: TypeDefinition) throws -> Bool {
        try type.hasAttribute(namespace: namespace, name: "ExperimentalAttribute")
    }

    public static func getDeprecations(_ attributable: some Attributable) throws -> [Deprecation] {
        return try attributable.attributes.filter { try $0.type.namespace == namespace && $0.type.name == "DeprecatedAttribute" }
            .map {
                let arguments = try $0.arguments
                guard arguments.count >= 3 else { throw InvalidMetadataError.attributeArguments }

                guard case .constant(let messageConstant) = arguments[0],
                    case .string(let message) = messageConstant,
                    case .constant(let typeConstant) = arguments[1],
                    case .int32(let typeValue) = typeConstant,
                    let kind = Deprecation.Kind(rawValue: typeValue) else { throw InvalidMetadataError.attributeArguments }

                return Deprecation(message: message, kind: kind,
                    applicability: try toVersionApplicability(arguments[2...]))
            }
    }

    internal static func toVersionApplicability(_ arguments: ArraySlice<Attribute.Value>) throws -> VersionApplicability {
        guard arguments.count >= 1 && arguments.count <= 2 else { throw InvalidMetadataError.attributeArguments }

        var context: VersionApplicability.Context?
        if arguments.count == 2 {
            guard case .constant(let contextConstant) = arguments.last! else { throw InvalidMetadataError.attributeArguments }
            switch contextConstant {
                case .string(let contractName):
                    context = .contract(name: contractName)
                case .int32(let platformValue):
                    guard let platform = Platform(rawValue: platformValue) else { throw InvalidMetadataError.attributeArguments }
                    context = .platform(platform)
                default:
                    throw InvalidMetadataError.attributeArguments
            }
        }

        guard case .constant(let versionConstant) = arguments.first!,
            case .uint32(let version) = versionConstant else { throw InvalidMetadataError.attributeArguments }

        return VersionApplicability(version: .init(unpacking: version), context: context)
    }

    public static func hasApiContract(_ struct: StructDefinition) throws -> Bool {
        try `struct`.hasAttribute(namespace: namespace, name: "ApiContractAttribute")
    }

    public static func getContractVersion(_ type: TypeDefinition) throws -> ContractVersion {
        guard let attribute = try type.firstAttribute(namespace: namespace, name: "ContractVersionAttribute") else {
            throw InvalidMetadataError.attributeArguments
        }

        // Three possible constructors:
        // - ContractVersionAttribute(uint version)
        // - ContractVersionAttribute(Type contract, uint version)
        // - ContractVersionAttribute(string contract, uint version)
        let arguments = try attribute.arguments
        guard arguments.count == 1 || arguments.count == 2 else { throw InvalidMetadataError.attributeArguments }

        let contract: ContractVersion.Contract?
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

        return ContractVersion(contract: contract, version: .init(unpacking: version))
    }

    public static func getLengthParameterIndex(_ param: Param) throws -> Int? {
        guard let attribute = try param.firstAttribute(namespace: namespace, name: "LengthIsAttribute") else { return nil }

        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .int32(let value) = constant else { throw InvalidMetadataError.attributeArguments }
        return Int(value)
    }
}
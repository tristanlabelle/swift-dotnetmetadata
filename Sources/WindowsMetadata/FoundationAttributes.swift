import DotNetMetadata
import struct Foundation.UUID

/// Provides methods for retrieving data from well-known attributes from the Windows.Foundation.Metadata namespace.
public enum FoundationAttributes {
    public static let namespace = "Windows.Foundation.Metadata"

    public static func hasProtected(_ attributed: some Attributable) throws -> Bool {
        try attributed.hasAttribute(namespace: namespace, name: "ProtectedAttribute")
    }

    public static func hasInternal(_ attributed: some Attributable) throws -> Bool {
        try attributed.hasAttribute(namespace: namespace, name: "InternalAttribute")
    }

    public static func hasVariant(_ type: TypeDefinition) throws -> Bool {
        try type.hasAttribute(namespace: namespace, name: "ProtectedAttribute")
    }

    public static func hasAllowMultiple(_ type: ClassDefinition) throws -> Bool {
        try type.hasAttribute(namespace: namespace, name: "AllowMultipleAttribute")
    }

    public static func hasExperimental(_ type: TypeDefinition) throws -> Bool {
        try type.hasAttribute(namespace: namespace, name: "ExperimentalAttribute")
    }

    public static func getExclusiveTo(_ interface: InterfaceDefinition) throws -> ClassDefinition? {
        guard let attribute = try interface.firstAttribute(namespace: namespace, name: "ExclusiveToAttribute") else { return nil }
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .type(let target) = arguments[0],
            let targetClass = target as? ClassDefinition else { throw InvalidMetadataError.attributeArguments }
        return targetClass
    }

    public static func getActivatableData(_ class: ClassDefinition) throws -> [ActivatableData] {
        return try `class`.attributes.filter { try $0.type.namespace == namespace && $0.type.name == "ActivatableAttribute" }
            .map {
                let arguments = try $0.arguments
                guard arguments.count >= 1 else { throw InvalidMetadataError.attributeArguments }

                if case .type(let definition) = arguments[0] {
                    guard let type = definition as? InterfaceDefinition else { throw InvalidMetadataError.attributeArguments }
                    return ActivatableData(type: type, startVersion: try toStartVersion(arguments[1...]))
                }
                else {
                    return ActivatableData(startVersion: try toStartVersion(arguments[...]))
                }
            }
    }

    public static func getStaticInterfaces(_ class: ClassDefinition) throws -> [StaticInterface] {
        return try `class`.attributes.filter { try $0.type.namespace == namespace && $0.type.name == "StaticAttribute" }
            .map {
                let arguments = try $0.arguments
                guard arguments.count >= 2 else { throw InvalidMetadataError.attributeArguments }
                guard case .type(let definition) = arguments[0],
                    let type = definition as? InterfaceDefinition else { throw InvalidMetadataError.attributeArguments }
                return StaticInterface(type: type, startVersion: try toStartVersion(arguments[1...]))
            }
    }

    private static func toStartVersion(_ arguments: ArraySlice<Attribute.Value>) throws -> StartVersion {
        guard arguments.count >= 1 else { throw InvalidMetadataError.attributeArguments }

        var context: StartVersion.Context?
        if arguments.count == 2 {
            guard case .constant(let contextConstant) = arguments.last! else { throw InvalidMetadataError.attributeArguments }
            switch contextConstant {
                case .string(let contractName):
                    context = .contract(name: contractName)
                case .int32(let platform):
                    context = .platform(platform == 0 ? Platform.windows : Platform.windowsPhone)
                default:
                    throw InvalidMetadataError.attributeArguments
            }
        }

        guard case .constant(let versionConstant) = arguments.first!,
            case .uint32(let version) = versionConstant else { throw InvalidMetadataError.attributeArguments }

        return StartVersion(version: .init(unpacking: version), context: context)
    }

    public static func isDefaultInterface(_ baseInterface: BaseInterface) throws -> Bool {
        try baseInterface.hasAttribute(namespace: namespace, name: "DefaultAttribute")
    }

    public static func getDefaultInterface(_ class: ClassDefinition) throws -> BoundType? {
        try `class`.baseInterfaces.first { try isDefaultInterface($0) }?.interface
    }

    public static func hasDefaultOverload(_ method: Method) throws -> Bool {
        try method.hasAttribute(namespace: namespace, name: "DefaultOverloadAttribute")
    }

    public static func getOverloadName(_ method: Method) throws -> String? {
        guard let attribute = try method.firstAttribute(namespace: namespace, name: "OverloadAttribute") else { return nil }
        guard try attribute.arguments.count == 1,
            case .constant(let constant) = try attribute.arguments[0],
            case .string(let name) = constant else {
            return nil // TODO: Throw?
        }
        return name
    }

    public static func getOverloadNameOrName(_ method: Method) throws -> String {
        try getOverloadName(method) ?? method.name
    }

    public static func hasNoException(_ method: Method) throws -> Bool {
        try method.hasAttribute(namespace: namespace, name: "NoExceptionAttribute")
    }

    public static func hasNoException(_ property: Property) throws -> Bool {
        try property.hasAttribute(namespace: namespace, name: "NoExceptionAttribute")
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

    public static func getGuid(_ delegate: DelegateDefinition) throws -> UUID {
        try getGuid(delegate as TypeDefinition)
    }

    public static func getGuid(_ interface: InterfaceDefinition) throws -> UUID {
        try getGuid(interface as TypeDefinition)
    }

    private static func getGuid(_ type: TypeDefinition) throws -> UUID {
        // [Windows.Foundation.Metadata.Guid(1516535814u, 33850, 19881, 134, 91, 157, 38, 229, 223, 173, 123)]
        guard let attribute = try type.firstAttribute(namespace: namespace, name: "GuidAttribute") else {
            throw InvalidMetadataError.attributeArguments
        }

        let arguments = try attribute.arguments
        guard arguments.count == 11 else { throw InvalidMetadataError.attributeArguments }

        func toConstant(_ value: Attribute.Value) throws -> Constant {
            switch value {
                case let .constant(constant): return constant
                default: throw InvalidMetadataError.attributeArguments
            }
        }

        guard case .uint32(let a) = try toConstant(arguments[0]) else { throw InvalidMetadataError.attributeArguments }
        guard case .uint16(let b) = try toConstant(arguments[1]) else { throw InvalidMetadataError.attributeArguments }
        guard case .uint16(let c) = try toConstant(arguments[2]) else { throw InvalidMetadataError.attributeArguments }
        let rest = try arguments[3...].map {
            guard case .uint8(let value) = try toConstant($0) else { throw InvalidMetadataError.attributeArguments }
            return value
        }

        return UUID(uuid: (
            UInt8((a >> 24) & 0xFF), UInt8((a >> 16) & 0xFF), UInt8((a >> 8) & 0xFF), UInt8((a >> 0) & 0xFF),
            UInt8((b >> 8) & 0xFF), UInt8((b >> 0) & 0xFF),
            UInt8((c >> 8) & 0xFF), UInt8((c >> 0) & 0xFF),
            rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]
        ))
    }
}
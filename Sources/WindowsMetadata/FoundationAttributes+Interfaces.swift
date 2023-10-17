import DotNetMetadata
import struct Foundation.UUID

// Attributes applying to interfaces
extension FoundationAttributes {
    public static func getExclusiveTo(_ interface: InterfaceDefinition) throws -> ClassDefinition? {
        guard let attribute = try interface.firstAttribute(namespace: namespace, name: "ExclusiveToAttribute") else { return nil }
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .type(let target) = arguments[0],
            let targetClass = target as? ClassDefinition else { throw InvalidMetadataError.attributeArguments }
        return targetClass
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
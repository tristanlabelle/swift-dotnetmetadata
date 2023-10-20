import DotNetMetadata
import struct Foundation.UUID

public enum GuidAttribute: AttributeType {
    public static var namespace: String { "Windows.Foundation.Metadata" }
    public static var name: String { "GuidAttribute" }
    public static var validOn: AttributeTargets { .interface | .delegate }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> UUID {
        // [Windows.Foundation.Metadata.Guid(1516535814u, 33850, 19881, 134, 91, 157, 38, 229, 223, 173, 123)]
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

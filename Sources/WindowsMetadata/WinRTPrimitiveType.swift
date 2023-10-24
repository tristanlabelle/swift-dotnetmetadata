import DotNetMetadata

public enum WinRTPrimitiveType: Hashable {
    case boolean
    case int(size: IntegerSize, signed: Bool)
    case float(double: Bool)
    case guid
    case string
    case object
}

extension WinRTPrimitiveType: CustomStringConvertible {
    public var name: String {
        switch self {
            case .boolean: return "Boolean"
            case .int(let size, let signed):
                switch size {
                    case .int8: return signed ? "Int8" : "UInt8"
                    case .int16: return signed ? "Int16" : "UInt16"
                    case .int32: return signed ? "Int32" : "UInt32"
                    case .int64: return signed ? "Int64" : "UInt64"
                    case .intPtr: fatalError()
                }
            case .float(let double): return double ? "Double" : "Single"
            case .guid: return "Guid"
            case .string: return "String"
            case .object: return "Object"
        }
    }

    public var description: String { name }
}

extension WinRTPrimitiveType {
    public static func fromSystemType(name systemName: String) -> WinRTPrimitiveType? {
        switch systemName {
            case "Boolean": return .boolean
            case "Byte": return .int(size: .int8, signed: false)
            case "SByte": return .int(size: .int8, signed: true)
            case "UInt16": return .int(size: .int16, signed: false)
            case "Int16": return .int(size: .int16, signed: true)
            case "UInt32": return .int(size: .int32, signed: false)
            case "Int32": return .int(size: .int32, signed: true)
            case "UInt64": return .int(size: .int64, signed: false)
            case "Int64": return .int(size: .int64, signed: true)
            case "Single": return .float(double: false)
            case "Double": return .float(double: true)
            case "Guid": return .guid
            case "String": return .string
            case "Object": return .object
            default: return nil
        }
    }
}

extension WinRTPrimitiveType {
    public var midlName: String {
        switch self {
            case .boolean: return "boolean"
            case .int(let size, let signed):
                switch size {
                    case .int8: return signed ? "INT8" : "UINT8"
                    case .int16: return signed ? "INT16" : "UINT16"
                    case .int32: return signed ? "INT32" : "UINT32"
                    case .int64: return signed ? "INT64" : "UINT64"
                    case .intPtr: fatalError()
                }
            case .float(let double): return double ? "double" : "float"
            case .guid: return "GUID"
            case .string: return "HSTRING"
            case .object: return "IInspectable"
        }
    }
}

import DotNetMetadata

// Types from the mscorlib System namespace which are usable from WinRT
public enum WinRTPrimitiveType: Hashable {
    case boolean
    case integer(WinRTIntegerType)
    case float(double: Bool)
    case char
    case guid
    case string
}

extension WinRTPrimitiveType: CustomStringConvertible {
    public var name: String {
        switch self {
            case .boolean: return "Boolean"
            case .integer(let type): return type.name
            case .float(let double): return double ? "Double" : "Single"
            case .char: return "Char16"
            case .guid: return "Guid"
            case .string: return "String"
        }
    }

    public var description: String { name }
}

extension WinRTPrimitiveType {
    public init?(fromName name: String) {
        switch name {
            case "Boolean": self = .boolean
            case "Byte": self = .integer(.uint8)
            case "Int16": self = .integer(.int16)
            case "UInt16": self = .integer(.uint16)
            case "Int32": self = .integer(.int32)
            case "UInt32": self = .integer(.uint32)
            case "Int64": self = .integer(.int64)
            case "UInt64": self = .integer(.uint64)
            case "Single": self = .float(double: false)
            case "Double": self = .float(double: true)
            case "Char16": self = .char
            case "Guid": self = .guid
            case "String": self = .string
            default: return nil
        }
    }
}

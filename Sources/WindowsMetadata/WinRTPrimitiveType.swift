import DotNetMetadata

// Types from the mscorlib System namespace which are usable from WinRT
public enum WinRTPrimitiveType: Hashable {
    case boolean
    case integer(WinRTIntegerType)
    case float(double: Bool)
    case char16
    case guid
    case string
}

extension WinRTPrimitiveType {
    public static var uint8: WinRTPrimitiveType { .integer(.uint8) }
    public static var int16: WinRTPrimitiveType { .integer(.int16)  }
    public static var uint16: WinRTPrimitiveType { .integer(.uint16) }
    public static var int32: WinRTPrimitiveType { .integer(.int32) }
    public static var uint32: WinRTPrimitiveType { .integer(.uint32) }
    public static var int64: WinRTPrimitiveType { .integer(.int64) }
    public static var uint64: WinRTPrimitiveType { .integer(.uint64) }
    public static var single: WinRTPrimitiveType { .float(double: false) }
    public static var double: WinRTPrimitiveType { .float(double: true) }
}

extension WinRTPrimitiveType: CustomStringConvertible {
    public var name: String {
        switch self {
            case .boolean: return "Boolean"
            case .integer(let type): return type.name
            case .float(let double): return double ? "Double" : "Single"
            case .char16: return "Char16"
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
            case "Byte": self = .uint8
            case "Int16": self = .int16
            case "UInt16": self = .uint16
            case "Int32": self = .int32
            case "UInt32": self = .uint32
            case "Int64": self = .int64
            case "UInt64": self = .uint64
            case "Single": self = .single
            case "Double": self = .double
            case "Char16": self = .char16
            case "Guid": self = .guid
            case "String": self = .string
            default: return nil
        }
    }

    public init?(fromSystemNamespaceType name: String) {
        // System namespace names match WinRT names except for Char16
        switch name {
            case "Char": self = .char16
            case "Char16": return nil
            default: self.init(fromName: name)
        }
    }
}

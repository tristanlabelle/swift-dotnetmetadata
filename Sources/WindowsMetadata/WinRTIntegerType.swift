import DotNetMetadata

public enum WinRTIntegerType: Hashable {
    // No Int8
    case uint8
    case int16
    case uint16
    case int32
    case uint32
    case int64
    case uint64
    // No IntPtr/UIntPtr
}

extension WinRTIntegerType {
    public init?(size: IntegerSize, signed: Bool) {
        switch (size, signed) {
            case (.int8, false): self = .uint8
            case (.int16, true): self = .int16
            case (.int16, false): self = .uint16
            case (.int32, true): self = .int32
            case (.int32, false): self = .uint32
            case (.int64, true): self = .int64
            case (.int64, false): self = .uint64
            default: return nil
        }
    }

    public var size: IntegerSize {
        switch self {
            case .uint8: return .int8
            case .int16: return .int16
            case .uint16: return .int16
            case .int32: return .int32
            case .uint32: return .int32
            case .int64: return .int64
            case .uint64: return .int64
        }
    }

    public var isSigned: Bool {
        return self == .int16 || self == .int32 || self == .int64
    }
}

extension WinRTIntegerType: CustomStringConvertible {
    public var name: String {
        switch self {
            case .uint8: return "UInt8"
            case .int16: return "Int16"
            case .uint16: return "UInt16"
            case .int32: return "Int32"
            case .uint32: return "UInt32"
            case .int64: return "Int64"
            case .uint64: return "UInt64"
        }
    }

    public var description: String { name }
}
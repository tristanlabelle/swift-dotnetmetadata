import DotNetMDFormat

public enum Constant: Hashable {
    case boolean(Bool)
    case char(UInt16)
    case i1(Int8)
    case u1(UInt8)
    case i2(Int16)
    case u2(UInt16)
    case i4(Int32)
    case u4(UInt32)
    case i8(Int64)
    case u8(UInt64)
    case r4(Float)
    case r8(Double)
    case string(String)
    case null
}

extension Constant {
    init(buffer: UnsafeRawBufferPointer, type: ConstantType) throws {
        switch (type, buffer.count) {
            case (.boolean, 1): self = .boolean(buffer.load(as: UInt8.self) != 0)
            case (.char, 2): self = .char(buffer.load(as: UInt16.self))
            case (.i1, 1): self = .i1(buffer.load(as: Int8.self))
            case (.u1, 1): self = .u1(buffer.load(as: UInt8.self))
            case (.i2, 2): self = .i2(buffer.load(as: Int16.self))
            case (.u2, 2): self = .u2(buffer.load(as: UInt16.self))
            case (.i4, 4): self = .i4(buffer.load(as: Int32.self))
            case (.u4, 4): self = .u4(buffer.load(as: UInt32.self))
            case (.i8, 8): self = .i8(buffer.load(as: Int64.self))
            case (.u8, 8): self = .u8(buffer.load(as: UInt64.self))
            case (.r4, 4): self = .r4(buffer.load(as: Float.self))
            case (.r8, 8): self = .r8(buffer.load(as: Double.self))
            case (.string, _):
                // UTF-8 or UTF-16?
                fatalError("Not implemented: String content decoding")
            case (.nullRef, 0): self = .null
            default:
                throw InvalidFormatError.signatureBlob
        }
    }
}
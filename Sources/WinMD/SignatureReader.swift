enum SignatureReader {
    public static func readType(buffer: UnsafeRawBufferPointer) throws -> TypeSig {
        var remainder = buffer
        guard let token = ElementTypeToken(rawValue: remainder.consume(type: UInt8.self).pointee) else {
            throw InvalidFormatError.signatureBlob
        }

        switch token {
            case .void: return .void
            case .boolean: return .boolean
            case .char: return .char
            case .i1: return .integer(size: ._1, signed: true)
            case .u1: return .integer(size: ._1, signed: false)
            case .i2: return .integer(size: ._2, signed: true)
            case .u2: return .integer(size: ._2, signed: false)
            case .i4: return .integer(size: ._4, signed: true)
            case .u4: return .integer(size: ._4, signed: false)
            case .i8: return .integer(size: ._8, signed: true)
            case .u8: return .integer(size: ._8, signed: false)
            case .i: return .integer(size: .native, signed: true)
            case .u: return .integer(size: .native, signed: false)
            case .r4: return .real(double: false)
            case .r8: return .real(double: true)
            case .object: return .object
            case .string: return .string
            default: throw InvalidFormatError.signatureBlob
        }
    }
}
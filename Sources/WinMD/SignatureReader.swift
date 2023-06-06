public enum SignatureReader {
    public static func readType(blob: UnsafeRawBufferPointer) throws -> TypeSig {
        var remainder = blob
        let result = try consumeType(buffer: &remainder)
        if remainder.count > 0 { throw InvalidFormatError.signatureBlob }
        return result
    }

    static func consumeType(buffer: inout UnsafeRawBufferPointer) throws -> TypeSig {
        switch consumeToken(buffer: &buffer) {
            case Token.void: return .void
            case Token.boolean: return .boolean
            case Token.char: return .char
            case Token.i1: return .integer(size: ._1, signed: true)
            case Token.u1: return .integer(size: ._1, signed: false)
            case Token.i2: return .integer(size: ._2, signed: true)
            case Token.u2: return .integer(size: ._2, signed: false)
            case Token.i4: return .integer(size: ._4, signed: true)
            case Token.u4: return .integer(size: ._4, signed: false)
            case Token.i8: return .integer(size: ._8, signed: true)
            case Token.u8: return .integer(size: ._8, signed: false)
            case Token.i: return .integer(size: .native, signed: true)
            case Token.u: return .integer(size: .native, signed: false)
            case Token.r4: return .real(double: false)
            case Token.r8: return .real(double: true)
            case Token.object: return .object
            case Token.string: return .string
            default: throw InvalidFormatError.signatureBlob
        }
    }

    public static func readMethodDef(blob: UnsafeRawBufferPointer) throws -> MethodDefSig {
        var remainder = blob
        let result = try consumeMethodDef(buffer: &remainder)
        if remainder.count > 0 { throw InvalidFormatError.signatureBlob }
        return result
    }

    static func consumeMethodDef(buffer: inout UnsafeRawBufferPointer) throws -> MethodDefSig {
        guard consumeToken(buffer: &buffer) == Token.default else {
            fatalError("Not implemented")
        }

        let paramCount = consumeCompressedInt(buffer: &buffer)
        let retType = try consumeType(buffer: &buffer)
        let paramTypes = try (0 ..< paramCount).map { _ in
            try consumeType(buffer: &buffer)
        }

        return MethodDefSig(
            hasThis: false,
            explicitThis: false,
            retType: retType,
            params: paramTypes)
    }

    public static func readField(blob: UnsafeRawBufferPointer) throws -> FieldSig {
        var remainder = blob
        let result = try consumeField(buffer: &remainder)
        if remainder.count > 0 { throw InvalidFormatError.signatureBlob }
        return result
    }
    
    static func consumeField(buffer: inout UnsafeRawBufferPointer) throws -> FieldSig {
        guard consumeToken(buffer: &buffer) == Token.field else {
            throw InvalidFormatError.signatureBlob
        }

        return FieldSig(type: try consumeType(buffer: &buffer))
    }

    static func consumeToken(buffer: inout UnsafeRawBufferPointer) -> UInt8 {
        buffer.consume(type: UInt8.self).pointee
    }

    static func consumeCompressedInt(buffer: inout UnsafeRawBufferPointer) -> Int {
        fatalError()
    }
}
extension TypeSig {
    public init(blob: UnsafeRawBufferPointer) throws {
        var remainder = blob
        try self.init(consuming: &remainder)
        if remainder.count > 0 { throw InvalidFormatError.signatureBlob }
    }

    init(consuming buffer: inout UnsafeRawBufferPointer) throws {
        switch SigToken.consume(buffer: &buffer) {
            // Leaf types
            case SigToken.ElementType.boolean: self = .boolean
            case SigToken.ElementType.char: self = .char
            case SigToken.ElementType.i1: self = .integer(size: .int8, signed: true)
            case SigToken.ElementType.u1: self = .integer(size: .int8, signed: false)
            case SigToken.ElementType.i2: self = .integer(size: .int16, signed: true)
            case SigToken.ElementType.u2: self = .integer(size: .int16, signed: false)
            case SigToken.ElementType.i4: self = .integer(size: .int32, signed: true)
            case SigToken.ElementType.u4: self = .integer(size: .int32, signed: false)
            case SigToken.ElementType.i8: self = .integer(size: .int64, signed: true)
            case SigToken.ElementType.u8: self = .integer(size: .int64, signed: false)
            case SigToken.ElementType.i: self = .integer(size: .intPtr, signed: true)
            case SigToken.ElementType.u: self = .integer(size: .intPtr, signed: false)
            case SigToken.ElementType.r4: self = .real(double: false)
            case SigToken.ElementType.r8: self = .real(double: true)
            case SigToken.ElementType.object: self = .object
            case SigToken.ElementType.string: self = .string

            case SigToken.ElementType.`class`: self = .class(try consumeTypeDefOrRefEncoded(buffer: &buffer))
            case SigToken.ElementType.valueType: self = .valueType(try consumeTypeDefOrRefEncoded(buffer: &buffer))

            // Compound types
            default: throw InvalidFormatError.signatureBlob
        }
    }
}

extension MethodDefSig {
    public init(blob: UnsafeRawBufferPointer) throws {
        var remainder = blob
        try self.init(consuming: &remainder)
        if remainder.count > 0 { throw InvalidFormatError.signatureBlob }
    }

    init(consuming buffer: inout UnsafeRawBufferPointer) throws {
        let callingConvention = SigToken.consume(buffer: &buffer)
        let hasThis = (callingConvention & SigToken.CallingConvention.hasThis) != 0
        let hasExplicitThis = hasThis && (callingConvention & SigToken.CallingConvention.explicitThis) != 0

        guard (callingConvention & SigToken.CallingConvention.mask) == SigToken.CallingConvention.default else {
            fatalError("Not implemented")
        }

        var paramCount = Int(consumeCompressedUInt(buffer: &buffer))
        let returnParam = try ParamSig(consuming: &buffer, return: true)

        let explicitThis: TypeSig?
        if hasExplicitThis {
            assert(paramCount > 0)
            explicitThis = try TypeSig(consuming: &buffer)
            paramCount -= 1
        } else {
            explicitThis = nil
        }

        let params = try (0 ..< paramCount).map { _ in
            try ParamSig(consuming: &buffer, return: false)
        }

        self.init(
            hasThis: hasThis,
            explicitThis: explicitThis,
            returnParam: returnParam,
            params: params)
    }
}

extension ParamSig {
    init(consuming buffer: inout UnsafeRawBufferPointer, return: Bool) throws {
        if `return` && SigToken.tryConsume(buffer: &buffer, token: SigToken.ElementType.void) {
            self.init(customMods: [], byRef: false, type: .void)
        }
        else {
            let byRef = SigToken.tryConsume(buffer: &buffer, token: SigToken.ElementType.byref)
            let type = try TypeSig(consuming: &buffer)
            self.init(customMods: [], byRef: byRef, type: type)
        }
    }
}

extension FieldSig {
    public init(blob: UnsafeRawBufferPointer) throws {
        var remainder = blob
        try self.init(consuming: &remainder)
        if remainder.count > 0 { throw InvalidFormatError.signatureBlob }
    }

    init(consuming buffer: inout UnsafeRawBufferPointer) throws {
        guard SigToken.tryConsume(buffer: &buffer, token: SigToken.CallingConvention.field) else {
            throw InvalidFormatError.signatureBlob
        }

        self.init(
            customMods: [],
            type: try TypeSig(consuming: &buffer))
    }
}

// §II.23.2.8
fileprivate func consumeTypeDefOrRefEncoded(buffer: inout UnsafeRawBufferPointer) throws -> MetadataToken {
    let encoded = consumeCompressedUInt(buffer: &buffer)
    let tag = encoded & 0b11
    let index = encoded >> 2

    switch tag {
        case 0: return .init(tableIndex: .typeDef, oneBasedRowIndex: index)
        case 1: return .init(tableIndex: .typeRef, oneBasedRowIndex: index)
        case 2: return .init(tableIndex: .typeSpec, oneBasedRowIndex: index)
        default: throw InvalidFormatError.signatureBlob
    }
}
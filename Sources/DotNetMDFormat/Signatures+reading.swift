import Foundation

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

            case SigToken.ElementType.`class`: self = .class(token: try consumeTypeDefOrRefEncoded(buffer: &buffer, allowSpec: true))
            case SigToken.ElementType.valueType: self = .valueType(token: try consumeTypeDefOrRefEncoded(buffer: &buffer, allowSpec: true))

            case SigToken.ElementType.szarray:
                let customMods = try consumeCustomMods(buffer: &buffer)
                self = .szarray(customMods: customMods, element: try TypeSig(consuming: &buffer))

            case SigToken.ElementType.var:
                let index = consumeCompressedUInt(buffer: &buffer)
                self = .var(index: index)

            case SigToken.ElementType.mvar:
                let index = consumeCompressedUInt(buffer: &buffer)
                self = .mvar(index: index)

            case let b:
                print(b)
                fflush(stdout)
                throw InvalidFormatError.signatureBlob
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
            customMods: try consumeCustomMods(buffer: &buffer),
            type: try TypeSig(consuming: &buffer))
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
        let customMods = try consumeCustomMods(buffer: &buffer)
        if `return` && SigToken.tryConsume(buffer: &buffer, token: SigToken.ElementType.void) {
            self.init(customMods: customMods, byRef: false, type: .void)
        }
        else {
            let byRef = SigToken.tryConsume(buffer: &buffer, token: SigToken.ElementType.byref)
            let type = try TypeSig(consuming: &buffer)
            self.init(customMods: customMods, byRef: byRef, type: type)
        }
    }
}

extension PropertySig {
    public init(blob: UnsafeRawBufferPointer) throws {
        var remainder = blob
        try self.init(consuming: &remainder)
        if remainder.count > 0 { throw InvalidFormatError.signatureBlob }
    }

    init(consuming buffer: inout UnsafeRawBufferPointer) throws {
        let hasThis = SigToken.tryConsume(buffer: &buffer, token: SigToken.CallingConvention.property | SigToken.CallingConvention.hasThis)
        guard hasThis || SigToken.tryConsume(buffer: &buffer, token: SigToken.CallingConvention.property) else {
            throw InvalidFormatError.signatureBlob
        }

        let paramCount = Int(consumeCompressedUInt(buffer: &buffer))
        let customMods = try consumeCustomMods(buffer: &buffer)
        let type = try TypeSig(consuming: &buffer)
        let params = try (0 ..< paramCount).map { _ in
            try ParamSig(consuming: &buffer, return: false)
        }

        self.init(
            hasThis: hasThis,
            customMods: customMods,
            type: type,
            params: params)
    }
}

// §II.23.2.8
fileprivate func consumeTypeDefOrRefEncoded(buffer: inout UnsafeRawBufferPointer, allowSpec: Bool) throws -> TypeDefOrRef {
    let encoded = consumeCompressedUInt(buffer: &buffer)
    let tag = encoded & 0b11
    let index = encoded >> 2

    if tag == 0 {
        return .typeDef(.init(oneBased: index))
    }
    else if tag == 1 {
        return .typeRef(.init(oneBased: index))
    } else if tag == 2 && allowSpec {
        return .typeSpec(.init(oneBased: index))
    }

    throw InvalidFormatError.signatureBlob
}

fileprivate func consumeCustomMods(buffer: inout UnsafeRawBufferPointer) throws -> [CustomMod] {
    var customMods: [CustomMod] = []
    while true {
        let isRequired = SigToken.tryConsume(buffer: &buffer, token: SigToken.ElementType.cmodReqd)
        guard isRequired || SigToken.tryConsume(buffer: &buffer, token: SigToken.ElementType.cmodOpt) else {
            break
        }

        let type = try consumeTypeDefOrRefEncoded(buffer: &buffer, allowSpec: false)
        customMods.append(.init(isRequired: isRequired, type: type))
    }

    return customMods
}
extension TypeSig {
    public init(blob: UnsafeRawBufferPointer) throws {
        var remainder = blob
        try self.init(consuming: &remainder)
        if remainder.count > 0 { throw InvalidFormatError.signatureBlob }
    }

    init(consuming buffer: inout UnsafeRawBufferPointer) throws {
        switch Token.consume(buffer: &buffer) {
            // Leaf types
            case Token.ElementType.boolean: self = .boolean
            case Token.ElementType.char: self = .char
            case Token.ElementType.i1: self = .integer(size: .int8, signed: true)
            case Token.ElementType.u1: self = .integer(size: .int8, signed: false)
            case Token.ElementType.i2: self = .integer(size: .int16, signed: true)
            case Token.ElementType.u2: self = .integer(size: .int16, signed: false)
            case Token.ElementType.i4: self = .integer(size: .int32, signed: true)
            case Token.ElementType.u4: self = .integer(size: .int32, signed: false)
            case Token.ElementType.i8: self = .integer(size: .int64, signed: true)
            case Token.ElementType.u8: self = .integer(size: .int64, signed: false)
            case Token.ElementType.i: self = .integer(size: .intPtr, signed: true)
            case Token.ElementType.u: self = .integer(size: .intPtr, signed: false)
            case Token.ElementType.r4: self = .real(double: false)
            case Token.ElementType.r8: self = .real(double: true)
            case Token.ElementType.object: self = .object
            case Token.ElementType.string: self = .string

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
        let callingConvention = Token.consume(buffer: &buffer)
        let hasThis = (callingConvention & Token.CallingConvention.hasThis) != 0
        let hasExplicitThis = hasThis && (callingConvention & Token.CallingConvention.explicitThis) != 0

        guard (callingConvention & Token.CallingConvention.mask) == Token.CallingConvention.default else {
            fatalError("Not implemented")
        }

        var paramCount = consumeCompressedInt(buffer: &buffer)

        let retType = try TypeSig(consuming: &buffer)

        let explicitThis: TypeSig?
        if hasExplicitThis {
            explicitThis = try TypeSig(consuming: &buffer)
            paramCount -= 1
        } else {
            explicitThis = nil
        }

        let params = try (0 ..< paramCount).map { _ in
            try ParamSig(consuming: &buffer)
        }

        self.init(
            hasThis: hasThis,
            explicitThis: explicitThis,
            retType: retType,
            params: params)
    }
}

extension ParamSig {
    init(consuming buffer: inout UnsafeRawBufferPointer) throws {
        let byRef = Token.tryConsume(buffer: &buffer, token: Token.ElementType.byref)
        let type = try TypeSig(consuming: &buffer)
        self.init(customMods: [], byRef: byRef, type: type)
    }
}

extension FieldSig {
    public init(blob: UnsafeRawBufferPointer) throws {
        var remainder = blob
        try self.init(consuming: &remainder)
        if remainder.count > 0 { throw InvalidFormatError.signatureBlob }
    }

    init(consuming buffer: inout UnsafeRawBufferPointer) throws {
        guard Token.consume(buffer: &buffer) == Token.CallingConvention.field else {
            throw InvalidFormatError.signatureBlob
        }

        self.init(type: try TypeSig(consuming: &buffer))
    }
}

fileprivate func consumeCompressedInt(buffer: inout UnsafeRawBufferPointer) -> Int {
    fatalError("Not implemented: Reading compressed ints in signatures")
}

fileprivate enum Token {
    static func consume(buffer: inout UnsafeRawBufferPointer) -> UInt8 {
        buffer.consume(type: UInt8.self).pointee
    }

    static func tryConsume(buffer: inout UnsafeRawBufferPointer, token: UInt8) -> Bool {
        guard buffer.count > 0 else { return false }
        guard buffer[0] == token else { return false }
        buffer.consume(type: UInt8.self)
        return true
    }

    // CorElementType.ELEMENT_TYPE_*
    enum ElementType {
        static let `end`: UInt8 = 0x00
        static let void: UInt8 = 0x01
        static let boolean: UInt8 = 0x02
        static let char: UInt8 = 0x03
        static let i1: UInt8 = 0x04
        static let u1: UInt8 = 0x05
        static let i2: UInt8 = 0x06
        static let u2: UInt8 = 0x07
        static let i4: UInt8 = 0x08
        static let u4: UInt8 = 0x09
        static let i8: UInt8 = 0x0a
        static let u8: UInt8 = 0x0b
        static let r4: UInt8 = 0x0c
        static let r8: UInt8 = 0x0d
        static let string: UInt8 = 0x0e

        static let ptr: UInt8 = 0x0f
        static let byref: UInt8 = 0x10

        static let valueType: UInt8 = 0x11
        static let `class`: UInt8 = 0x12
        static let `var`: UInt8 = 0x13
        static let array: UInt8 = 0x14
        static let genericInst: UInt8 = 0x15
        static let typedByRef: UInt8 = 0x16

        static let i: UInt8 = 0x18
        static let u: UInt8 = 0x19
        static let fnptr: UInt8 = 0x1b
        static let object: UInt8 = 0x1c
        static let szarray: UInt8 = 0x1d
        static let mvar: UInt8 = 0x1e

        static let cmodReqd: UInt8 = 0x1f
        static let cmodOpt: UInt8 = 0x20
        
        static let `internal`: UInt8 = 0x21
        static let max: UInt8 = 0x22
        
        static let modifier: UInt8 = 0x40
        static let sentinel: UInt8 = 0x41
        static let pinned: UInt8 = 0x45

        static let systemType: UInt8 = 0x50
    }

    // CorCallingConvention.IMAGE_CEE_CS_CALLCONV_*
    enum CallingConvention {
        static let `default`: UInt8 = 0x00

        static let vararg: UInt8 = 0x05
        static let field: UInt8 = 0x06
        static let localSig: UInt8 = 0x07
        static let property: UInt8 = 0x08
        static let unmgd: UInt8 = 0x09
        static let genericInst: UInt8 = 0x0A
        static let nativeVarArg: UInt8 = 0x0B
        static let max: UInt8 = 0x0C

        static let mask: UInt8 = 0x0F
        static let generic: UInt8 = 0x10
        static let hasThis: UInt8 = 0x20
        static let explicitThis: UInt8 = 0x40
    }

    enum CustomAttr {
        static let boxedObject: UInt8 = 0x51
        static let field: UInt8 = 0x53
        static let property: UInt8 = 0x54
        static let `enum`: UInt8 = 0x55
    }

    static let nullString: UInt8 = 0xFF
}
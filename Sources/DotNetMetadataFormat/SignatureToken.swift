enum SigToken {
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

        // "This modifier can occur in the definition of LocalVarSig (§23.2.6),
        // Param (§23.2.10), RetType (§23.2.11) or Field (§23.2.4)"
        static let ptr: UInt8 = 0x0f

        // "This modifier can only occur in the definition of LocalVarSig (§23.2.6), 
        // Param (§23.2.10) or RetType (§23.2.11)"
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

    enum CustomAttrib {
        static let prolog: UInt16 = 0x0001
        static let prolog_0: UInt8 = 0x01
        static let prolog_1: UInt8 = 0x00
        static let boxedObject: UInt8 = 0x51
        static let field: UInt8 = 0x53
        static let property: UInt8 = 0x54
        static let `enum`: UInt8 = 0x55
    }

    static let nullString: UInt8 = 0xFF
}
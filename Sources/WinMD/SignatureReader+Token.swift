extension SignatureReader {
    enum Token {
        static let `default`: UInt8 = 0x00
        static let `end`: UInt8 = 0x00
        static let void: UInt8 = 0x01
        static let boolean: UInt8 = 0x02
        static let char: UInt8 = 0x03
        static let i1: UInt8 = 0x04
        static let u1: UInt8 = 0x05
        static let i2: UInt8 = 0x06
        static let field: UInt8 = 0x06
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
        static let modifier: UInt8 = 0x40
        static let sentinel: UInt8 = 0x41
        static let pinned: UInt8 = 0x45
        static let systemType: UInt8 = 0x50

        enum CustomAttr {
            static let boxedObject: UInt8 = 0x51
            static let field: UInt8 = 0x53
            static let property: UInt8 = 0x54
            static let `enum`: UInt8 = 0x55
        }

        static let nullString: UInt8 = 0xFF
    }
}
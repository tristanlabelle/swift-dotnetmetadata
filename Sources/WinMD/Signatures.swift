public enum TypeSig {
    case void
    case boolean
    case char
    case integer(size: IntegerSize, signed: Bool)
    case real(double: Bool)
    case string
    case object
    indirect case ptr(TypeSig)
    indirect case byref(TypeSig)
    case valueType(MetadataToken)
    case `class`(MetadataToken)
    case `var`(UInt)
    case fnptr
    case szarray
    case mvar(UInt)
}

public enum IntegerSize {
    case _1
    case _2
    case _4
    case _8
    case native
}

public struct MethodDefSig {
    public var hasThis: Bool
    public var explicitThis: Bool
    // default/vararg/generic
    public var retType: TypeSig
    public var params: [TypeSig]
}

extension MethodDefSig {
    public init(blob: UnsafeRawBufferPointer) throws {
        self = try SignatureReader.readMethodDef(blob: blob)
    }
}

public struct FieldSig {
    // customMods
    public var type: TypeSig
}

extension FieldSig {
    public init(blob: UnsafeRawBufferPointer) throws {
        self = try SignatureReader.readField(blob: blob)
    }
}
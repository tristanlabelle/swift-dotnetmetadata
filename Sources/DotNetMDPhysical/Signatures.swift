public enum TypeSig {
    case boolean
    case char
    case integer(size: IntegerSize, signed: Bool)
    case real(double: Bool)
    case string
    case object
    indirect case ptr(TypeSig)
    case valueType(MetadataToken)
    case `class`(MetadataToken)
    case `var`(UInt)
    case fnptr
    indirect case szarray(TypeSig)
    case mvar(UInt)
}

public struct CustomMod {
    public var isRequired: Bool
    public var type: ModType
    
    public enum ModType {
        case def(Table<TypeDef>.RowIndex)
        case ref(Table<TypeRef>.RowIndex)
    }
}

public struct ParamSig {
    public var customMods: [CustomMod]
    public var byRef: Bool
    public var type: TypeSig
}

public struct MethodDefSig {
    public var hasThis: Bool
    public var explicitThis: Bool
    // default/vararg/generic
    public var retType: TypeSig
    public var params: [ParamSig]
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
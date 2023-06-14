public enum TypeSig {
    case void
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

public struct FieldSig {
    public var customMods: [CustomMod]
    public var type: TypeSig
}

public struct MethodDefSig {
    public var hasThis: Bool
    public var explicitThis: TypeSig?
    // default/vararg/generic
    public var returnParam: ParamSig
    public var params: [ParamSig]
}

public struct PropertySig {
    public var hasThis: Bool
    public var customMods: [CustomMod]
    public var type: TypeSig
    public var params: [ParamSig]
}

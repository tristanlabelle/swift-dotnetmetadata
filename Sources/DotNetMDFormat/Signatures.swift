public enum TypeSig {
    case void
    case boolean
    case char
    case integer(size: IntegerSize, signed: Bool)
    case real(double: Bool)
    case string
    case object
    indirect case ptr(target: TypeSig)
    indirect case defOrRef(index: TypeDefOrRef, class: Bool, genericArgs: [TypeSig])
    case genericArg(index: UInt32, method: Bool)
    indirect case szarray(customMods: [CustomMod], element: TypeSig)
    case fnptr
}

public struct CustomMod {
    public var isRequired: Bool
    public var type: TypeDefOrRef
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

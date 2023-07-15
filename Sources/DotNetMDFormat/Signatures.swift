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

public struct CustomAttrib {
    public var fixedArgs: [Elem]
    public var namedArgs: [NamedArg]

    public struct NamedArg {
        public var memberKind: MemberKind
        public var name: String
        public var value: Elem
    }

    public enum MemberKind {
        case field
        case property
    }

    public enum Elem {
        // TODO: Consolidate with Constant enum
        case boolean(Bool)
        case char(UTF16.CodeUnit)
        case int8(Int8)
        case uint8(UInt8)
        case int16(Int16)
        case uint16(UInt16)
        case int32(Int32)
        case uint32(UInt32)
        case int64(Int64)
        case uint64(UInt64)
        case single(Float)
        case double(Double)
        case string(String)
        case type(fullName: String, assemblyName: String, assemblyVersion: AssemblyVersion, assemblyCulture: String, assemblyPublicKey: [UInt8])
        indirect case boxed(Elem)
        case array([Elem])
    }
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

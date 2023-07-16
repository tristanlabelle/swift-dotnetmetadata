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
    indirect case szarray(customMods: [CustomModSig], element: TypeSig)
    case fnptr
}

public struct CustomAttribSig {
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
        case constant(Constant)
        case type(fullName: String, assemblyName: String, assemblyVersion: AssemblyVersion, assemblyCulture: String, assemblyPublicKey: [UInt8])
        indirect case boxed(Elem)
        case array([Elem])
    }
}

public struct CustomModSig {
    public var isRequired: Bool
    public var type: TypeDefOrRef
}

public struct ParamSig {
    public var customMods: [CustomModSig]
    public var byRef: Bool
    public var type: TypeSig
}

public struct FieldSig {
    public var customMods: [CustomModSig]
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
    public var customMods: [CustomModSig]
    public var type: TypeSig
    public var params: [ParamSig]
}

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
        case type(fullName: String, assembly: AssemblyIdentity)
        indirect case boxed(Elem)
        case array([Elem])
    }
}

public struct CustomModSig {
    public var isRequired: Bool
    public var type: TypeDefOrRef
}

public struct FieldSig {
    public var customMods: [CustomModSig]
    public var type: TypeSig
}

public struct MethodSig {
    public var thisParam: ThisParam
    public var callingConv: CallingConv
    public var returnParam: ParamSig
    public var params: [ParamSig]

    public enum ThisParam {
        case none
        case implicit
        case explicit(TypeSig)
    }

    public enum CallingConv {
        case `default`(genericArity: UInt32 = 0)
        case vararg(extraCount: UInt32)
    }
}

extension MethodSig.ThisParam {
    public var isPresent: Bool {
        switch self {
            case .none: return false
            default: return true
        }
    }
}

public struct ParamSig {
    public var customMods: [CustomModSig]
    public var byRef: Bool
    public var type: TypeSig
}

public struct PropertySig {
    public var hasThis: Bool
    public var customMods: [CustomModSig]
    public var type: TypeSig
    public var params: [ParamSig]
}

public enum TypeSig {
    case void
    case boolean
    case char
    case integer(size: IntegerSize, signed: Bool)
    case real(double: Bool)
    case string
    case object
    indirect case ptr(customMods: [CustomModSig], to: TypeSig) // Target may be .void
    indirect case defOrRef(index: TypeDefOrRef, class: Bool, genericArgs: [TypeSig])
    case genericParam(index: UInt32, method: Bool)
    indirect case szarray(customMods: [CustomModSig], of: TypeSig)
    case fnptr
}

extension TypeSig {
    public static var int8: TypeSig { .integer(size: .int8, signed: true) }
    public static var uint8: TypeSig { .integer(size: .int8, signed: false) }
    public static var int16: TypeSig { .integer(size: .int16, signed: true) }
    public static var uint16: TypeSig { .integer(size: .int16, signed: false) }
    public static var int32: TypeSig { .integer(size: .int32, signed: true) }
    public static var uint32: TypeSig { .integer(size: .int32, signed: false) }
    public static var int64: TypeSig { .integer(size: .int64, signed: true) }
    public static var uint64: TypeSig { .integer(size: .int64, signed: false) }
}
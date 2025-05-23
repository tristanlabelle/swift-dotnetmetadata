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
        case type(fullName: String, assembly: AssemblyIdentity?)
        indirect case boxed(Elem)
        case array([Elem])
    }

    public enum ElemType {
        case boolean
        case char
        case integer(size: IntegerSize, signed: Bool)
        case real(double: Bool)
        case string
        case type
        indirect case array(of: ElemType)
    }
}

public struct CustomModSig {
    public var isRequired: Bool
    public var type: CodedIndices.TypeDefOrRef
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
    indirect case defOrRef(index: CodedIndices.TypeDefOrRef, class: Bool, genericArgs: [TypeSig])
    case genericParam(index: UInt32, method: Bool)
    indirect case array(of: TypeSig, shape: ArrayShapeSig)
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

public struct ArrayShapeSig {
    /// The number of dimensions in the array. Must be greater than zero.
    public let rank: UInt32
    /// The explicitly specified static sizes for each array dimension.
    /// Unspecified values and zero values both indicate that the size is not known staticly.
    public let sizes: [UInt32]
    /// The explicitly specified static lower bounds for each array dimension.
    /// Unspecified values indicate a lower bound of zero.
    public let lowerBounds: [Int32]

    public init(rank: UInt32, sizes: [UInt32], lowerBounds: [Int32]) {
        precondition(rank > 0)
        precondition(UInt32(sizes.count) <= rank)
        precondition(UInt32(lowerBounds.count) <= rank)
        self.rank = rank
        self.lowerBounds = lowerBounds
        self.sizes = sizes
    }

    public func getSize(dimension: Int) -> UInt32? {
        precondition(dimension >= 0 && dimension < rank)
        if dimension >= sizes.count { return nil }
        return sizes[dimension] == 0 ? nil : sizes[dimension]
    }

    public func getLowerBound(dimension: Int) -> Int32 {
        precondition(dimension >= 0 && dimension < rank)
        if dimension >= lowerBounds.count { return 0 }
        return lowerBounds[dimension]
    }

    public var isVector: Bool {
        rank == 1 && getLowerBound(dimension: 0) == 0 && getSize(dimension: 0) == nil
    }
}
// Avoid using "enum: UInt32" since that doesn't make the type 32-bit sized.
public struct AssemblyFlags: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let publicKey = Self(rawValue: 0x1)
    static let sideBySideCompatible = Self(rawValue: 0x2)
    static let reserved = Self(rawValue: 0x30)
    static let retargetable = Self(rawValue: 0x100)
    static let disableJITcompileOptimizer = Self(rawValue: 0x4000)
    static let enableJITCompileTracking = Self(rawValue: 0x8000)
}

public struct AssemblyHashAlgorithm: Hashable, Equatable, RawRepresentable {
    public typealias RawValue = UInt32

    public let rawValue: RawValue

    public init?(rawValue: RawValue) { self.rawValue = rawValue }
    public init(_ rawValue: RawValue) { self.rawValue = rawValue }

    static let none = Self(0)
    static let reserved_MD5 = Self(0x8003)
    static let sha1 = Self(0x8004)
}

public struct EventAttributes: OptionSet {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public static let specialName = Self(rawValue: 0x200)
    public static let rtSpecialName = Self(rawValue: 0x400)
}

public struct FieldAttributes: OptionSet {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public static let fieldAccessMask = Self(rawValue: 0x7)
    public static let compilerControlled = Self([])
    public static let `private` = Self(rawValue: 0x1)
    public static let famANDAssem = Self(rawValue: 0x2)
    public static let assembly = Self(rawValue: 0x3)
    public static let family = Self(rawValue: 0x4)
    public static let famORAssem = Self(rawValue: 0x5)
    public static let `public` = Self(rawValue: 0x6)
}

public struct GenericParamAttributes: OptionSet {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public static let varianceMask = Self(rawValue: 0x3)
    public static let none = Self([])
    public static let covariant = Self(rawValue: 0x1)
    public static let contravariant = Self(rawValue: 0x2)

    public static let specialConstaintMask = Self(rawValue: 0x1C)
    public static let referenceTypeConstraint = Self(rawValue: 0x4)
    public static let notNullableValueTypeConstraint = Self(rawValue: 0x8)
    public static let defaultConstructorConstraint = Self(rawValue: 0x10)
}

public struct MethodAttributes: OptionSet {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public static let memberAccessMask = Self(rawValue: 0x7)
    public static let compilerControlled = Self([])
    public static let `private` = Self(rawValue: 0x1)
    public static let famANDAssem = Self(rawValue: 0x2)
    public static let assem = Self(rawValue: 0x3)
    public static let family = Self(rawValue: 0x4)
    public static let famORAssem = Self(rawValue: 0x5)
    public static let `public` = Self(rawValue: 0x6)
    
    public static let `static` = Self(rawValue: 0x10)
    public static let `final` = Self(rawValue: 0x20)
    public static let virtual = Self(rawValue: 0x40)
    public static let hideBySig = Self(rawValue: 0x80)
    public static let vtableLayoutMask = Self(rawValue: 0x100)
    public static let reuseSlot = Self([])
    public static let newSlot = Self(rawValue: 0x100)
    public static let strict = Self(rawValue: 0x200)
    public static let abstract = Self(rawValue: 0x400)
    public static let specialName = Self(rawValue: 0x800)
    
    public static let pinvokeImpl = Self(rawValue: 0x2000)
    public static let unmanagedExport = Self(rawValue: 0x8)
    
    public static let rtSpecialName = Self(rawValue: 0x1000)
    public static let hasSecurity = Self(rawValue: 0x4000)
    public static let requireSecObject = Self(rawValue: 0x8000)
}

public struct MethodImplAttributes: OptionSet {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public static let codeTypeMaskMask = Self(rawValue: 0x3)
    public static let il = Self([])
    public static let native = Self(rawValue: 0x1)
    public static let optil = Self(rawValue: 0x2)
    public static let runtime = Self(rawValue: 0x3)
    
    public static let unmanagedMask = Self(rawValue: 0x4)
    public static let unmanaged = Self(rawValue: 0x4)
    public static let managed = Self([])
    
    public static let forwardRef = Self(rawValue: 0x10)
    public static let preserveSig = Self(rawValue: 0x80)
    public static let internalCall = Self(rawValue: 0x1000)
    public static let synchronized = Self(rawValue: 0x20)
    public static let noInlining = Self(rawValue: 0x8)
    public static let maxMethodImplVal = Self(rawValue: 0xFFFF)
    public static let noOptimization = Self(rawValue: 0x40)
}

public struct MethodSemanticsAttributes: OptionSet {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public static let setter = Self(rawValue: 0x1)
    public static let getter = Self(rawValue: 0x2)
    public static let other = Self(rawValue: 0x4)
    public static let addOn = Self(rawValue: 0x8)
    public static let removeOn = Self(rawValue: 0x10)
    public static let fire = Self(rawValue: 0x20)
}

public struct ParamAttributes: OptionSet {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public static let `in` = Self(rawValue: 0x1)
    public static let out = Self(rawValue: 0x2)
    public static let optional = Self(rawValue: 0x10)
    public static let hasDefault = Self(rawValue: 0x1000)
    public static let hasFieldMarshal = Self(rawValue: 0x2000)
    public static let unused = Self(rawValue: 0xcfe0)
}

public struct PropertyAttributes: OptionSet {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public static let specialName = Self(rawValue: 0x200)
    public static let rtSpecialName = Self(rawValue: 0x400)
    public static let hasDefault = Self(rawValue: 0x1000)
    public static let unused = Self(rawValue: 0xE9FF)
}

public struct TypeAttributes: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let visibilityMask = Self(rawValue: 0x7)
    public static let notPublic = Self([])
    public static let `public` = Self(rawValue: 0x1)
    public static let nestedPublic = Self(rawValue: 0x2)
    public static let nestedPrivate = Self(rawValue: 0x3)
    public static let nestedFamily = Self(rawValue: 0x4)
    public static let nestedAssembly = Self(rawValue: 0x5)
    public static let nestedFamANDAssem = Self(rawValue: 0x6)
    public static let nestedFamORAssem = Self(rawValue: 0x7)
    
    public static let layoutMask = Self(rawValue: 0x18)
    public static let autoLayout = Self([])
    public static let sequentialLayout = Self(rawValue: 0x8)
    public static let explicitLayout = Self(rawValue: 0x10)
    
    public static let classSemanticsMask = Self(rawValue: 0x20)
    public static let `class` = Self([])
    public static let interface = Self(rawValue: 0x20)
    
    public static let abstract = Self(rawValue: 0x80)
    public static let sealed = Self(rawValue: 0x100)
    public static let specialName = Self(rawValue: 0x400)
    
    public static let `import` = Self(rawValue: 0x1000)
    public static let serializable = Self(rawValue: 0x2000)
    
    public static let stringFormatMask = Self(rawValue: 0x30000)
    public static let ansiClass = Self([])
    public static let unicodeClass = Self(rawValue: 0x10000)
    public static let autoClass = Self(rawValue: 0x20000)
    public static let customFormatClass = Self(rawValue: 0x30000)
    
    public static let customStringFormatMask = Self(rawValue: 0xC00000)
    
    public static let beforeFieldInit = Self(rawValue: 0x100000)
    public static let rtSpecialName = Self(rawValue: 0x800)
    public static let hasSecurity = Self(rawValue: 0x40000)
}
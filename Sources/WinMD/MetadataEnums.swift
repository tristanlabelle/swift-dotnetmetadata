
public struct AssemblyFlags: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let publicKey = AssemblyFlags(rawValue: 0x1)
    static let sideBySideCompatible = AssemblyFlags(rawValue: 0x2)
    static let reserved = AssemblyFlags(rawValue: 0x30)
    static let retargetable = AssemblyFlags(rawValue: 0x100)
    static let disableJITcompileOptimizer = AssemblyFlags(rawValue: 0x4000)
    static let enableJITCompileTracking = AssemblyFlags(rawValue: 0x8000)
}

public enum AssemblyHashAlgorithm: UInt32 {
    case none = 0
    case reserved_MD5 = 0x8003
    case sha1 = 0x8004
}

public struct FieldAttributes: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let fieldAccessMask = FieldAttributes(rawValue: 0x7)
    public static let compilerControlled = FieldAttributes([])
    public static let `private` = FieldAttributes(rawValue: 0x1)
    public static let famANDAssem = FieldAttributes(rawValue: 0x2)
    public static let assembly = FieldAttributes(rawValue: 0x3)
    public static let family = FieldAttributes(rawValue: 0x4)
    public static let famORAssem = FieldAttributes(rawValue: 0x5)
    public static let `public` = FieldAttributes(rawValue: 0x6)
}

public struct MethodAttributes: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let memberAccessMask = MethodAttributes(rawValue: 0x7)
    public static let compilerControlled = MethodAttributes([])
    public static let `private` = MethodAttributes(rawValue: 0x1)
    public static let famANDAssem = MethodAttributes(rawValue: 0x2)
    public static let assem = MethodAttributes(rawValue: 0x3)
    public static let family = MethodAttributes(rawValue: 0x4)
    public static let famORAssem = MethodAttributes(rawValue: 0x5)
    public static let `public` = MethodAttributes(rawValue: 0x6)
    
    public static let `static` = MethodAttributes(rawValue: 0x10)
    public static let `final` = MethodAttributes(rawValue: 0x20)
    public static let virtual = MethodAttributes(rawValue: 0x40)
    public static let hideBySig = MethodAttributes(rawValue: 0x80)
    public static let vtableLayoutMask = MethodAttributes(rawValue: 0x100)
    public static let reuseSlot = MethodAttributes([])
    public static let newSlot = MethodAttributes(rawValue: 0x100)
    public static let strict = MethodAttributes(rawValue: 0x200)
    public static let abstract = MethodAttributes(rawValue: 0x400)
    public static let specialName = MethodAttributes(rawValue: 0x800)
    
    public static let pinvokeImpl = MethodAttributes(rawValue: 0x2000)
    public static let unmanagedExport = MethodAttributes(rawValue: 0x8)
    
    public static let rtSpecialName = MethodAttributes(rawValue: 0x1000)
    public static let hasSecurity = MethodAttributes(rawValue: 0x4000)
    public static let requireSecObject = MethodAttributes(rawValue: 0x8000)
}

public struct MethodImplAttributes: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let codeTypeMaskMask = MethodAttributes(rawValue: 0x3)
    public static let il = MethodAttributes([])
    public static let native = MethodAttributes(rawValue: 0x1)
    public static let optil = MethodAttributes(rawValue: 0x2)
    public static let runtime = MethodAttributes(rawValue: 0x3)
    
    public static let unmanagedMask = MethodAttributes(rawValue: 0x4)
    public static let unmanaged = MethodAttributes(rawValue: 0x4)
    public static let managed = MethodAttributes([])
    
    public static let forwardRef = MethodAttributes(rawValue: 0x10)
    public static let preserveSig = MethodAttributes(rawValue: 0x80)
    public static let internalCall = MethodAttributes(rawValue: 0x1000)
    public static let synchronized = MethodAttributes(rawValue: 0x20)
    public static let noInlining = MethodAttributes(rawValue: 0x8)
    public static let maxMethodImplVal = MethodAttributes(rawValue: 0xFFFF)
    public static let noOptimization = MethodAttributes(rawValue: 0x40)
}

public struct ParamAttributes: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let `in` = MethodAttributes(rawValue: 0x1)
    public static let out = MethodAttributes(rawValue: 0x2)
    public static let optional = MethodAttributes(rawValue: 0x10)
    public static let hasDefault = MethodAttributes(rawValue: 0x1000)
    public static let hasFieldMarshal = MethodAttributes(rawValue: 0x2000)
    public static let unused = MethodAttributes(rawValue: 0xcfe0)
}

public struct TypeAttributes: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let visibilityMask = TypeAttributes(rawValue: 0x7)
    public static let notPublic = TypeAttributes([])
    public static let `public` = TypeAttributes(rawValue: 0x1)
    public static let nestedPublic = TypeAttributes(rawValue: 0x2)
    public static let nestedPrivate = TypeAttributes(rawValue: 0x3)
    public static let nestedFamily = TypeAttributes(rawValue: 0x4)
    public static let nestedAssembly = TypeAttributes(rawValue: 0x5)
    public static let nestedFamANDAssem = TypeAttributes(rawValue: 0x6)
    public static let nestedFamORAssem = TypeAttributes(rawValue: 0x7)
    
    public static let layoutMask = TypeAttributes(rawValue: 0x18)
    public static let autoLayout = TypeAttributes([])
    public static let sequentialLayout = TypeAttributes(rawValue: 0x8)
    public static let explicitLayout = TypeAttributes(rawValue: 0x10)
    
    public static let classSemanticsMask = TypeAttributes(rawValue: 0x20)
    public static let `class` = TypeAttributes([])
    public static let interface = TypeAttributes(rawValue: 0x20)
    
    public static let abstract = TypeAttributes(rawValue: 0x80)
    public static let sealed = TypeAttributes(rawValue: 0x100)
    public static let specialName = TypeAttributes(rawValue: 0x400)
    
    public static let `import` = TypeAttributes(rawValue: 0x1000)
    public static let serializable = TypeAttributes(rawValue: 0x2000)
    
    public static let stringFormatMask = TypeAttributes(rawValue: 0x30000)
    public static let ansiClass = TypeAttributes([])
    public static let unicodeClass = TypeAttributes(rawValue: 0x10000)
    public static let autoClass = TypeAttributes(rawValue: 0x20000)
    public static let customFormatClass = TypeAttributes(rawValue: 0x30000)
    
    public static let customStringFormatMask = TypeAttributes(rawValue: 0xC00000)
    
    public static let beforeFieldInit = TypeAttributes(rawValue: 0x100000)
    public static let rtSpecialName = TypeAttributes(rawValue: 0x800)
    public static let hasSecurity = TypeAttributes(rawValue: 0x40000)
}
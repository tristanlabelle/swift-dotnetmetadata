
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
    public static let Assembly = FieldAttributes(rawValue: 0x3)
    public static let family = FieldAttributes(rawValue: 0x4)
    public static let famORAssem = FieldAttributes(rawValue: 0x5)
    public static let `public` = FieldAttributes(rawValue: 0x6)
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
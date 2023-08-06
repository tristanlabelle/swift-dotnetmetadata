// Avoid using "enum: UInt32" since that doesn't make the type 32-bit sized.
public struct ConstantType: RawRepresentable, Hashable {
    public let rawValue: UInt8
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let boolean = Self(rawValue: 0x02)
    public static let char = Self(rawValue: 0x03)
    public static let i1 = Self(rawValue: 0x04)
    public static let u1 = Self(rawValue: 0x05)
    public static let i2 = Self(rawValue: 0x06)
    public static let u2 = Self(rawValue: 0x07)
    public static let i4 = Self(rawValue: 0x08)
    public static let u4 = Self(rawValue: 0x09)
    public static let i8 = Self(rawValue: 0x0a)
    public static let u8 = Self(rawValue: 0x0b)
    public static let r4 = Self(rawValue: 0x0c)
    public static let r8 = Self(rawValue: 0x0d)
    public static let string = Self(rawValue: 0x0e)

    public static let nullRef = Self(rawValue: 0x12)
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

    public static let `static` = Self(rawValue: 0x10)
    public static let initOnly = Self(rawValue: 0x20)
    public static let literal = Self(rawValue: 0x40)
    public static let notSerialized = Self(rawValue: 0x80)
    public static let specialName = Self(rawValue: 0x200)

    public static let pinvokeImpl = Self(rawValue: 0x2000)
    public static let rtSpecialName = Self(rawValue: 0x400)
    public static let hasFieldMarshal = Self(rawValue: 0x1000)
    public static let hasDefault = Self(rawValue: 0x8000)
    public static let hasFieldRVA = Self(rawValue: 0x100)
}

public struct FileAttributes: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let containsMetadata = Self([])
    public static let containsNoMetadata = Self(rawValue: 0x1)
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

    public static let specialConstraintMask = Self(rawValue: 0x1C)
    public static let referenceTypeConstraint = Self(rawValue: 0x4)
    public static let notNullableValueTypeConstraint = Self(rawValue: 0x8)
    public static let defaultConstructorConstraint = Self(rawValue: 0x10)
}

public struct ManifestResourceAttributes: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let visibilityMask = Self(rawValue: 0x7)
    public static let `public` = Self(rawValue: 0x1)
    public static let `private` = Self(rawValue: 0x2)
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

public struct PInvokeAttributes: OptionSet {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    public static let noMangle = Self(rawValue: 0x1)

    public static let charSetMask = Self(rawValue: 0x6)
    public static let charSetNotSpec = Self([])
    public static let charSetAnsi = Self(rawValue: 0x2)
    public static let charSetUnicode = Self(rawValue: 0x4)
    public static let charSetAuto = Self(rawValue: 0x6)

    public static let supportsLastError = Self(rawValue: 0x40)

    public static let callConvMask = Self(rawValue: 0x700)
    public static let callConvWinapi = Self(rawValue: 0x100)
    public static let callConvCdecl = Self(rawValue: 0x200)
    public static let callConvStdcall = Self(rawValue: 0x300)
    public static let callConvThiscall = Self(rawValue: 0x400)
    public static let callConvFastcall = Self(rawValue: 0x500)
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
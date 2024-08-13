public struct AssemblyFlags: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let publicKey = Self(rawValue: 0x1)
    public static let sideBySideCompatible = Self(rawValue: 0x2)
    public static let reserved = Self(rawValue: 0x30)
    public static let retargetable = Self(rawValue: 0x100)
    public static let windowsRuntime = Self(rawValue: 0x200)
    public static let disableJITcompileOptimizer = Self(rawValue: 0x4000)
    public static let enableJITCompileTracking = Self(rawValue: 0x8000)
}

public struct AssemblyHashAlgorithm: Hashable, Equatable, RawRepresentable {
    public typealias RawValue = UInt32

    public let rawValue: RawValue

    public init?(rawValue: RawValue) { self.rawValue = rawValue }
    public init(_ rawValue: RawValue) { self.rawValue = rawValue }

    public static let none = Self(0)
    public static let reserved_MD5 = Self(0x8003)
    public static let sha1 = Self(0x8004)
}
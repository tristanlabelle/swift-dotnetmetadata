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
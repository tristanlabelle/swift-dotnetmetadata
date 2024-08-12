public struct TwoPartVersion: Hashable, CustomStringConvertible {
    public var major: UInt16
    public var minor: UInt16

    public init(major: UInt16, minor: UInt16 = 0) {
        self.major = major
        self.minor = minor
    }

    public init(unpacking value: UInt32) {
        self.major = UInt16(value >> 16)
        self.minor = UInt16(value & 0xFFFF)
    }

    public var packed: UInt32 { UInt32(major) << 16 | UInt32(minor) }
    public var description: String { "\(major).\(minor)" }
}
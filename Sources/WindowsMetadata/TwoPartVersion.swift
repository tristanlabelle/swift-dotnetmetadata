public struct TwoPartVersion: Comparable, Hashable, CustomStringConvertible {
    public var major: UInt16
    public var minor: UInt16

    public init(major: UInt16, minor: UInt16 = 0) {
        self.major = major
        self.minor = minor
    }

    public init?(parsing str: String) {
        let components = str.split(separator: ".")
        guard components.count == 2 else { return nil }
        guard let major = UInt16(components[0]),
            let minor = UInt16(components[1]) else { return nil }
        self.major = major
        self.minor = minor
    }

    public init(unpacking value: UInt32) {
        self.major = UInt16(value >> 16)
        self.minor = UInt16(value & 0xFFFF)
    }

    public var packed: UInt32 { UInt32(major) << 16 | UInt32(minor) }
    public var description: String { "\(major).\(minor)" }

    public static func < (lhs: TwoPartVersion, rhs: TwoPartVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else {
            return lhs.minor < rhs.minor
        }
    }
}
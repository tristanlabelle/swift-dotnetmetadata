public struct AssemblyVersion: Comparable, Hashable, CustomStringConvertible {
    public static let all255 = AssemblyVersion(major: 255, minor: 255, buildNumber: 255, revisionNumber: 255)

    public var major: UInt16
    public var minor: UInt16
    public var buildNumber: UInt16
    public var revisionNumber: UInt16

    public var description: String { "\(major).\(minor).\(buildNumber).\(revisionNumber)" }

    public static func < (lhs: AssemblyVersion, rhs: AssemblyVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else if lhs.buildNumber != rhs.buildNumber {
            return lhs.buildNumber < rhs.buildNumber
        } else {
            return lhs.revisionNumber < rhs.revisionNumber
        }
    }
}
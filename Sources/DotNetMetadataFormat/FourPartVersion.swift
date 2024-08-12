public struct FourPartVersion: Comparable, Hashable, CustomStringConvertible {
    public static let zero = FourPartVersion()
    public static let all255 = FourPartVersion(major: 255, minor: 255, buildNumber: 255, revisionNumber: 255)

    public var major: UInt16
    public var minor: UInt16
    public var buildNumber: UInt16
    public var revisionNumber: UInt16

    public var description: String { "\(major).\(minor).\(buildNumber).\(revisionNumber)" }

    public init() {
        self.major = 0
        self.minor = 0
        self.buildNumber = 0
        self.revisionNumber = 0
    }

    public init(major: UInt16, minor: UInt16, buildNumber: UInt16 = 0, revisionNumber: UInt16 = 0) {
        self.major = major
        self.minor = minor
        self.buildNumber = buildNumber
        self.revisionNumber = revisionNumber
    }

    public init(parsing str: String) throws {
        let components = str.split(separator: ".")
        guard components.count == 4 else { fatalError() }
        self.major = UInt16(components[0])!
        self.minor = UInt16(components[1])!
        self.buildNumber = UInt16(components[2])!
        self.revisionNumber = UInt16(components[3])!
    }

    public static func < (lhs: FourPartVersion, rhs: FourPartVersion) -> Bool {
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
public struct Deprecation {
    public enum Kind: Int32, Hashable {
        /// Compilers and other tools should treat the entity as deprecated.
        /// This is the default.
        case deprecate = 0
        /// Compilers and other tools should treat the entity as removed.
        case remove = 1
    }

    public var message: String
    public var kind: Kind
    public var applicability: VersionApplicability

    public init(message: String, kind: Kind, applicability: VersionApplicability) {
        self.message = message
        self.kind = kind
        self.applicability = applicability
    }
}
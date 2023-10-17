import DotNetMetadata

public struct Composition {
    public enum Kind: Int32, Hashable {
        /// Indicates that access to the programming element is limited to other elements
        /// in the containing class or types derived from the containing class.
        case protected = 1
        /// Indicates that access to the programming element is not restricted.
        case `public` = 2
    }

    public var factory: InterfaceDefinition
    public var kind: Kind
    public var applicability: VersionApplicability

    public init(factory: InterfaceDefinition, kind: Kind, applicability: VersionApplicability) {
        self.factory = factory
        self.kind = kind
        self.applicability = applicability
    }
}

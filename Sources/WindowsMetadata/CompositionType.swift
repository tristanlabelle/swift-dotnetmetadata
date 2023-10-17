public enum CompositionType: Hashable {
    /// Indicates that access to the programming element is limited to other elements in the containing class or types derived from the containing class.
    case protected
    /// Indicates that access to the programming element is not restricted.
    case `public`
}

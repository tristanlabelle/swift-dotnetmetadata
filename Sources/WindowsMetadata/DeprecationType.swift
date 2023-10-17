public enum DeprecationType {
    /// Compilers and other tools should treat the entity as deprecated. This is the default.
    case deprecate
    /// Compilers and other tools should treat the entity as removed.
    case remove
}
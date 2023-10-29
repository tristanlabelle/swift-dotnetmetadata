public enum WinMDError: Hashable, Error {
    case missingAttribute
    /// A type was used from the System namespace which is not a WinRT base type
    case unexpectedType
}
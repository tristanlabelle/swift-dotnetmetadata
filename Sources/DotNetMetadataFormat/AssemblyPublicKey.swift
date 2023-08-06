public enum AssemblyPublicKey: Hashable {
    case full([UInt8]) // Full strong name key (.snk) file
    case token([UInt8]) // Last 8 bytes of SHA-1 of full key
}

extension AssemblyPublicKey {
    public static func from(bytes: [UInt8], isToken: Bool) -> AssemblyPublicKey {
        return isToken ? .token(bytes) : .full(bytes)
    }
}
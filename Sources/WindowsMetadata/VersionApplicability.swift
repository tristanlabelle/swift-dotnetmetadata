public struct VersionApplicability: Hashable {
    public enum Context: Hashable {
        case contract(name: String)
        case platform(Platform)
    }

    public var version: Version
    public var context: Context?

    public init(version: Version, context: Context? = nil) {
        self.version = version
        self.context = context
    }

    public init(version: Version, contractName: String) {
        self.version = version
        self.context = .contract(name: contractName)
    }

    public init(version: Version, platform: Platform) {
        self.version = version
        self.context = .platform(platform)
    }
}
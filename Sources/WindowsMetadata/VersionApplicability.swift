import DotNetMetadata

public struct VersionApplicability: Hashable {
    public enum Context: Hashable {
        case contract(name: String)
        case platform(Platform)
    }

    public var version: TwoPartVersion
    public var context: Context?

    public init(version: TwoPartVersion, context: Context? = nil) {
        self.version = version
        self.context = context
    }

    public init(version: TwoPartVersion, contractName: String) {
        self.version = version
        self.context = .contract(name: contractName)
    }

    public init(version: TwoPartVersion, platform: Platform) {
        self.version = version
        self.context = .platform(platform)
    }

    public static func decode(_ arguments: ArraySlice<Attribute.Value>) throws -> VersionApplicability {
        guard arguments.count >= 1 && arguments.count <= 2 else { throw InvalidMetadataError.attributeArguments }

        var context: VersionApplicability.Context?
        if arguments.count == 2 {
            guard case .constant(let contextConstant) = arguments.last! else { throw InvalidMetadataError.attributeArguments }
            switch contextConstant {
                case .string(let contractName):
                    context = .contract(name: contractName)
                case .int32(let platformValue):
                    guard let platform = Platform(rawValue: platformValue) else { throw InvalidMetadataError.attributeArguments }
                    context = .platform(platform)
                default:
                    throw InvalidMetadataError.attributeArguments
            }
        }

        guard case .constant(let versionConstant) = arguments.first!,
            case .uint32(let version) = versionConstant else { throw InvalidMetadataError.attributeArguments }

        return VersionApplicability(version: .init(unpacking: version), context: context)
    }
}
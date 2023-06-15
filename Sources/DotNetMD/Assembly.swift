import DotNetMDFormat

public class Assembly: CustomDebugStringConvertible {
    typealias Impl = AssemblyImpl

    public let context: MetadataContext
    private let impl: any AssemblyImpl

    init(context: MetadataContext, impl: any AssemblyImpl) throws {
        self.context = context
        self.impl = impl
        impl.initialize(owner: self)
    }

    public var name: String { impl.name }
    public var version: AssemblyVersion { impl.version }
    public var culture: String { impl.culture }
    public var definedTypes: [TypeDefinition] { impl.definedTypes }

    public var debugDescription: String {
        var result = "\(name), Version=\(version)"
        if !culture.isEmpty { result += ", Culture=\(culture)" }
        return result
    }

    public private(set) lazy var typesByFullName: [String: TypeDefinition] = {
        Dictionary(uniqueKeysWithValues: definedTypes.map { ($0.fullName, $0) })
    }()

    public func findDefinedType(fullName: String) -> TypeDefinition? {
        typesByFullName[fullName]
    }

    public func findDefinedType(namespace: String, name: String) -> TypeDefinition? {
        findDefinedType(fullName: "\(namespace).\(name)")
    }
}

internal protocol AssemblyImpl {
    func initialize(owner: Assembly)

    var name: String { get }
    var version: AssemblyVersion { get }
    var culture: String { get }
    var definedTypes: [TypeDefinition] { get }
}

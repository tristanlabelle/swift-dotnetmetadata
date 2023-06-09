import WinMD

public class Assembly: CustomDebugStringConvertible {
    typealias Impl = AssemblyImpl

    public let context: MetadataContext
    private let impl: any AssemblyImpl

    init(context: MetadataContext, impl: any AssemblyImpl) {
        self.context = context
        self.impl = impl
        impl.initialize(owner: self)
    }

    public var name: String { impl.name }
    public var version: AssemblyVersion { impl.version }
    public var culture: String { impl.culture }
    public var types: [TypeDefinition] { impl.types }

    public var debugDescription: String {
        var result = "\(name), Version=\(version)"
        if !culture.isEmpty { result += ", Culture=\(culture)" }
        return result
    }

    public private(set) lazy var typesByFullName: [String: TypeDefinition] = {
        Dictionary(uniqueKeysWithValues: types.map { ($0.fullName, $0) })
    }()

    public func findTypeDefinition(fullName: String) -> TypeDefinition? {
        typesByFullName[fullName]
    }

    public func findTypeDefinition(namespace: String, name: String) -> TypeDefinition? {
        findTypeDefinition(fullName: "\(namespace).\(name)")
    }
}

internal protocol AssemblyImpl {
    func initialize(owner: Assembly)

    var name: String { get }
    var version: AssemblyVersion { get }
    var culture: String { get }
    var types: [TypeDefinition] { get }
}

import WinMD

public class Assembly {
    typealias Impl = AssemblyImpl

    public let context: MetadataContext
    private let impl: any AssemblyImpl

    init(context: MetadataContext, impl: any AssemblyImpl) {
        self.context = context
        self.impl = impl
        impl.initialize(parent: self)
    }

    public var name: String { impl.name }
    public var version: AssemblyVersion { impl.version }
    public var types: [TypeDefinition] { impl.types }
    
    public private(set) lazy var typesByFullName: [String: TypeDefinition] = {
        Dictionary(uniqueKeysWithValues: types.map { ($0.fullName, $0) })
    }()

    public func findTypeDefinition(fullName: String) -> TypeDefinition? {
        typesByFullName[fullName]
    }
}

internal protocol AssemblyImpl {
    func initialize(parent: Assembly)

    var name: String { get }
    var version: AssemblyVersion { get }
    var types: [TypeDefinition] { get }
}

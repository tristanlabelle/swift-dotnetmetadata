import WinMD

public class TypeDefinition: CustomDebugStringConvertible {
    internal typealias Impl = TypeDefinitionImpl

    public let assembly: Assembly
    private let impl: any TypeDefinitionImpl

    init(assembly: Assembly, impl: any TypeDefinitionImpl) {
        self.assembly = assembly
        self.impl = impl
        impl.initialize(owner: self)
    }

    public var context: MetadataContext { assembly.context }

    public var name: String { impl.name }
    public var namespace: String { impl.namespace }
    internal var metadataFlags: WinMD.TypeAttributes { impl.metadataFlags }
    public var genericParams: [GenericTypeParam] { impl.genericParams }
    public var base: TypeDefinition? { impl.base }
    public var fields: [Field]  { impl.fields }
    public var methods: [Method] { impl.methods }
    public var properties: [Property] { impl.properties }
    public var events: [Event] { impl.events }

    public var debugDescription: String { "\(fullName) (\(assembly.name) \(assembly.version))" }
    
    public private(set) lazy var fullName: String = {
        let ns = namespace
        return ns.isEmpty ? name : "\(ns).\(name)"
    }()
    
    public var visibility: Visibility {
        switch metadataFlags.intersection(.visibilityMask) {
            case .public: return .public
            case .notPublic: return .assembly
            case .nestedFamily: return .family
            case .nestedFamORAssem: return .familyOrAssembly
            case .nestedFamANDAssem: return .familyAndAssembly
            case .nestedAssembly: return .assembly
            case .nestedPrivate: return .private
            default: fatalError()
        }
    }

    public var isNested: Bool {
        switch metadataFlags.intersection(.visibilityMask) {
            case .public, .notPublic: return false
            case .nestedFamily, .nestedFamORAssem, .nestedFamANDAssem,
                .nestedAssembly, .nestedPrivate: return true
            default: fatalError()
        }
    }
    
    public var isAbstract: Bool { metadataFlags.contains(TypeAttributes.abstract) }
    public var isSealed: Bool { metadataFlags.contains(TypeAttributes.sealed) }

    public func findSingleMethod(name: String) -> Method? { methods.single { $0.name == name } }
    public func findField(name: String) -> Field? { fields.first { $0.name == name } }
    public func findProperty(name: String) -> Property? { properties.first { $0.name == name } }
    public func findEvent(name: String) -> Event? { events.first { $0.name == name } }
}

internal protocol TypeDefinitionImpl {
    func initialize(owner: TypeDefinition)

    var name: String { get }
    var namespace: String { get }
    var metadataFlags: WinMD.TypeAttributes { get }
    var genericParams: [GenericTypeParam] { get }
    var base: TypeDefinition? { get }
    var fields: [Field]  { get }
    var methods: [Method] { get }
    var properties: [Property] { get }
    var events: [Event] { get }
}

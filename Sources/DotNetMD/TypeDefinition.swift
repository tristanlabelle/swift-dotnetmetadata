import DotNetMDFormat

/// An unbound type definition, which may have generic parameters.
public class TypeDefinition: CustomDebugStringConvertible {
    internal typealias Kind = TypeDefinitionKind
    internal typealias Impl = TypeDefinitionImpl

    public static let nestedTypeSeparator: Character = "/"
    public static let genericParamCountSeparator: Character = "`"

    public let assembly: Assembly
    private let impl: any TypeDefinitionImpl

    fileprivate init(assembly: Assembly, impl: any TypeDefinitionImpl) {
        self.assembly = assembly
        self.impl = impl
        impl.initialize(owner: self)
    }

    internal static func create(assembly: Assembly, impl: any TypeDefinitionImpl) -> TypeDefinition {
        switch impl.kind {
            case .class: return ClassDefinition(assembly: assembly, impl: impl)
            case .interface: return InterfaceDefinition(assembly: assembly, impl: impl)
            case .delegate: return DelegateDefinition(assembly: assembly, impl: impl)
            case .struct: return StructDefinition(assembly: assembly, impl: impl)
            case .enum: return EnumDefinition(assembly: assembly, impl: impl)
        }
    }

    public var context: MetadataContext { assembly.context }

    public var name: String { impl.name }
    public var namespace: String? { impl.namespace }
    internal var metadataAttributes: DotNetMDFormat.TypeAttributes { impl.metadataAttributes }
    public var enclosingType: TypeDefinition? { impl.enclosingType }
    public var genericParams: [GenericTypeParam] { impl.genericParams }
    public var base: BoundType? { impl.base }
    public var baseInterfaces: [BaseInterface] { impl.baseInterfaces }
    public var fields: [Field]  { impl.fields }
    public var methods: [Method] { impl.methods }
    public var properties: [Property] { impl.properties }
    public var events: [Event] { impl.events }
    public var attributes: [Attribute] { impl.attributes }

    public var debugDescription: String { "\(fullName) (\(assembly.name) \(assembly.version))" }

    public var nameWithoutGenericSuffix: String {
        let name = name
        guard let index = name.firstIndex(of: Self.genericParamCountSeparator) else { return name }
        return String(name[..<index])
    }

    public private(set) lazy var fullName: String = {
        if let enclosingType {
            assert(namespace == nil)
            return "\(enclosingType.fullName)\(Self.nestedTypeSeparator)\(name)"
        }
        return makeFullTypeName(namespace: namespace, name: name)
    }()

    public var visibility: Visibility { metadataAttributes.visibility }
    public var isNested: Bool { metadataAttributes.isNested }
    public var isAbstract: Bool { metadataAttributes.contains(TypeAttributes.abstract) }
    public var isSealed: Bool { metadataAttributes.contains(TypeAttributes.sealed) }
    public var isGeneric: Bool { !genericParams.isEmpty }

    public var layout: TypeLayout {
        switch metadataAttributes.layoutKind {
            case .auto: return .auto
            case .sequential:
                let layout = impl.classLayout
                return .sequential(pack: layout.pack == 0 ? nil : Int(layout.pack), minSize: Int(layout.size))
            case .explicit:
                return .explicit(minSize: Int(impl.classLayout.size))
        }
    }
    public var layoutKind: LayoutKind { metadataAttributes.layoutKind }

    public func findSingleMethod(name: String, inherited: Bool = false) -> Method? {
        methods.single { $0.name == name } ?? (inherited ? base?.definition.findSingleMethod(name: name, inherited: true) : nil)
    }

    public func findField(name: String, inherited: Bool = false) -> Field? {
        fields.first { $0.name == name } ?? (inherited ? base?.definition.findField(name: name, inherited: true) : nil)
    }

    public func findProperty(name: String, inherited: Bool = false) -> Property? {
        properties.first { $0.name == name } ?? (inherited ? base?.definition.findProperty(name: name, inherited: true) : nil)
    }

    public func findEvent(name: String, inherited: Bool = false) -> Event? {
        events.first { $0.name == name } ?? (inherited ? base?.definition.findEvent(name: name, inherited: true) : nil)
    }
}

public final class ClassDefinition: TypeDefinition {
    public var finalizer: Method? { findSingleMethod(name: "Finalize") }
}

public final class InterfaceDefinition: TypeDefinition {
}

public final class DelegateDefinition: TypeDefinition {
    public var invokeMethod: Method { findSingleMethod(name: "Invoke")! }
}

public final class StructDefinition: TypeDefinition {
}

public final class EnumDefinition: TypeDefinition {
    public var backingField: Field { fields.single { $0.name == "value__" }! }
    public var underlyingType: TypeDefinition { get throws { try backingField.type.asDefinition! } }
}

extension TypeDefinition: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: TypeDefinition, rhs: TypeDefinition) -> Bool { lhs === rhs }
}

internal enum TypeDefinitionKind {
    case `class`
    case interface
    case delegate
    case `struct`
    case `enum`
}

internal typealias ClassLayoutData = (pack: UInt16, size: UInt32)

internal protocol TypeDefinitionImpl {
    func initialize(owner: TypeDefinition)

    var name: String { get }
    var namespace: String? { get }
    var kind: TypeDefinitionKind { get }
    var metadataAttributes: DotNetMDFormat.TypeAttributes { get }
    var classLayout: ClassLayoutData { get }
    var enclosingType: TypeDefinition? { get }
    var genericParams: [GenericTypeParam] { get }
    var base: BoundType? { get }
    var baseInterfaces: [BaseInterface] { get }
    var fields: [Field]  { get }
    var methods: [Method] { get }
    var properties: [Property] { get }
    var events: [Event] { get }
    var attributes: [Attribute] { get }
}

public func makeFullTypeName(namespace: String?, name: String) -> String {
    if let namespace {
        return "\(namespace).\(name)"
    } else {
        return name
    }
}

public func makeFullTypeName(namespace: String?, enclosingName: String, nestedNames: [String]) -> String {
    var result: String
    if let namespace {
        result = "\(namespace).\(enclosingName)"
    }
    else {
        result = enclosingName
    }
    for nestedName in nestedNames {
        result.append(TypeDefinition.nestedTypeSeparator)
        result += nestedName
    }
    return result
}
/// A type definition with all generic parameters specified.
/// Valid: "NonGenericType", "GenericType<ConcreteType>", "GenericType<TypeParameter>"
/// Invalid: "GenericType<>"
public struct BoundTypeOf<Definition: TypeDefinition>: Hashable {
    public let definition: Definition
    public let genericArgs: [TypeNode]

    public init(_ definition: Definition, genericArgs: [TypeNode]) {
        precondition(definition.genericArity == genericArgs.count)
        self.definition = definition
        self.genericArgs = genericArgs
    }

    public var typeErased: BoundType { .init(definition, genericArgs: []) }
    public var asNode: TypeNode { .bound(typeErased) }
    public var isParameterized: Bool { !genericArgs.allSatisfy { !$0.isParameterized } }

    public func bindGenericParams(_ binding: (GenericParam) throws -> TypeNode) rethrows -> Self {
        .init(definition, genericArgs: try genericArgs.map { try $0.bindGenericParams(binding) })
    }

    public func bindGenericParams(typeArgs: [TypeNode]?, methodArgs: [TypeNode]?) -> Self {
        bindGenericParams { $0.bind(typeArgs: typeArgs, methodArgs: methodArgs) }
    }
}

public typealias BoundType = BoundTypeOf<TypeDefinition>
extension TypeDefinition {
    public func bindType(genericArgs: [TypeNode] = []) -> BoundType {
        .init(self, genericArgs: genericArgs)
    }
}

public typealias BoundStruct = BoundTypeOf<StructDefinition>
extension StructDefinition {
    public typealias Bound = BoundStruct
    public func bind(genericArgs: [TypeNode] = []) -> BoundStruct {
        .init(self, genericArgs: genericArgs)
    }
}

public typealias BoundClass = BoundTypeOf<ClassDefinition>
extension ClassDefinition {
    public typealias Bound = BoundClass
    public func bind(genericArgs: [TypeNode] = []) -> BoundClass {
        .init(self, genericArgs: genericArgs)
    }
}

public typealias BoundInterface = BoundTypeOf<InterfaceDefinition>
extension InterfaceDefinition {
    public typealias Bound = BoundInterface
    public func bind(genericArgs: [TypeNode] = []) -> BoundInterface {
        .init(self, genericArgs: genericArgs)
    }
}

public typealias BoundDelegate = BoundTypeOf<DelegateDefinition>
extension DelegateDefinition {
    public typealias Bound = BoundDelegate
    public func bind(genericArgs: [TypeNode] = []) -> BoundDelegate {
        .init(self, genericArgs: genericArgs)
    }
}
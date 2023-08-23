/// A type definition with all generic parameters specified.
/// Valid: NonGenericType, GenericType<ConcreteType>, GenericType<TypeParameter>
/// Invalid: GenericType<>
public struct BoundType: Hashable {
    public let definition: TypeDefinition
    public let genericArgs: [TypeNode]

    public init(_ definition: TypeDefinition, genericArgs: [TypeNode]) {
        precondition(definition.genericArity == genericArgs.count)
        self.definition = definition
        self.genericArgs = genericArgs
    }

    public var asNode: TypeNode { .bound(self) }
    public var isParameterized: Bool { !genericArgs.allSatisfy { !$0.isParameterized } }
}

extension TypeDefinition {
    public func bind(genericArgs: [TypeNode] = []) -> BoundType {
        .init(self, genericArgs: genericArgs)
    }
}
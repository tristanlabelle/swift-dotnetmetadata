/// A type definition with all generic parameters, whether direct or on enclosing types, bound.
/// Valid:
/// - NonGenericType
/// - NonGenericType.NestedNonGenericType
/// - NonGenericType.NestedGenericType<TypeNode>
/// - GenericType<TypeNode>
/// - GenericType<TypeNode>.NestedNonGenericType
/// - GenericType<TypeNode>.NestedGenericType<TypeNode>
/// Invalid:
/// - NonGenericType.NestedGenericType<>
/// - GenericType<>
/// - GenericType<>.NestedNonGenericType
/// - GenericType<>.NestedGenericType<TypeNode>
/// - GenericType<TypeNode>.NestedGenericType<>
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
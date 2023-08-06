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
    public let fullGenericArgs: [TypeNode]

    public init(_ definition: TypeDefinition, fullGenericArgs: [TypeNode]) {
        precondition(definition.fullGenericParams.count == fullGenericArgs.count)
        self.definition = definition
        self.fullGenericArgs = fullGenericArgs
    }

    public var asNode: TypeNode { .bound(self) }
    public var isClosed: Bool { fullGenericArgs.allSatisfy { $0.isClosed } }
    public var isOpen: Bool { !isClosed }
}

extension TypeDefinition {
    public func bind(fullGenericArgs: [TypeNode] = []) -> BoundType {
        .init(self, fullGenericArgs: fullGenericArgs)
    }
}
/// A type definition with any and all generic arguments bound.
public struct BoundType {
    public let definition: TypeDefinition
    public let genericArgs: [TypeNode]

    public init(_ definition: TypeDefinition, genericArgs: [TypeNode]) {
        precondition(definition.genericParams.count == genericArgs.count)
        self.definition = definition
        self.genericArgs = genericArgs
    }

    public var asNode: TypeNode { .bound(self) }
}

extension BoundType: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.definition === rhs.definition && lhs.genericArgs == rhs.genericArgs
    }
}

extension TypeDefinition {
    public func bind(genericArgs: [TypeNode] = []) -> BoundType {
        .init(self, genericArgs: genericArgs)
    }
}
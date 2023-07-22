/// A type as can describe a variable, parameter, or return type.
/// Types are arranged as a tree and cannot reference unbound type definitions.
public enum TypeNode: Hashable {
    case bound(BoundType)
    indirect case array(element: TypeNode)
    case genericArg(param: GenericParam)
    indirect case pointer(element: TypeNode)
}

extension TypeNode {
    public var asDefinition: TypeDefinition? {
        switch self {
            case .bound(let bound): return bound.definition
            default: return nil
        }
    }
}

extension TypeDefinition {
    public func bindNode(genericArgs: [TypeNode] = []) -> TypeNode {
        .bound(bind(genericArgs: genericArgs))
    }
}
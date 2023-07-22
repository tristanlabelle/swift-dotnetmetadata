/// A type as can describe a variable, parameter, or return type.
/// Types are arranged as a tree and cannot reference unbound type definitions.
public enum TypeNode {
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

extension TypeNode: Equatable {
    public static func ==(lhs: TypeNode, rhs: TypeNode) -> Bool {
        switch (lhs, rhs) {
            case (.bound(let lhs), .bound(let rhs)):
                return lhs == rhs
            case (.array(let lhs), .array(let rhs)):
                return lhs == rhs
            case (.genericArg(let lhs), .genericArg(let rhs)):
                return lhs === rhs
            case (.pointer(let lhs), .pointer(let rhs)):
                return lhs == rhs
            default:
                return false
        }
    }
}

extension TypeDefinition {
    public func bindNode(genericArgs: [TypeNode] = []) -> TypeNode {
        .bound(bind(genericArgs: genericArgs))
    }
}
/// A type as can describe a variable, parameter, or return type.
/// Types are arranged as a tree and cannot reference unbound type definitions.
public enum TypeNode: Hashable {
    case bound(BoundType)
    indirect case array(element: TypeNode)
    case genericArg(param: GenericParam)
    indirect case pointer(element: TypeNode)
}

extension TypeNode {
    public static func bound(_ definition: TypeDefinition, genericArgs: [TypeNode] = []) -> TypeNode {
        .bound(BoundType(definition, genericArgs: genericArgs))
    }

    public var asDefinition: TypeDefinition? {
        switch self {
            case .bound(let bound): return bound.definition
            default: return nil
        }
    }

    public var isValueType: Bool? {
        switch self {
            case .bound(let bound): return bound.definition.isValueType
            case .array: return false
            case .genericArg(let param):
                if param.isValueType { return true }
                if param.isReferenceType { return false }
                return nil
            case .pointer: return true
        }
    }

    public var isReferenceType: Bool? {
        switch isValueType {
            case .some(let isValueType): return !isValueType
            case .none: return nil
        }
    }

    /// Indicates whether this TypeNode always refers to the same type
    /// due to containing no generic arguments.
    public var isClosed: Bool {
        switch self {
            case .bound(let bound): return bound.isClosed
            case .array(let element): return element.isClosed
            case .genericArg: return false
            case .pointer(let element): return element.isClosed
        }
    }

    /// Indicates whether this TypeNode contains generic arguments
    public var isOpen: Bool { !isClosed }

    public func resolveGenericParams(_ resolver: (GenericParam) throws -> TypeNode) rethrows -> TypeNode {
        switch self {
            case .bound(let bound):
                return .bound(bound.definition, genericArgs: try bound.genericArgs.map { try $0.resolveGenericParams(resolver) })
            case .array(let element):
                return .array(element: try element.resolveGenericParams(resolver))
            case .genericArg(let param):
                return try resolver(param)
            case .pointer(let element):
                return .pointer(element: try element.resolveGenericParams(resolver))
        }
    }
}

extension TypeDefinition {
    public func bindNode(genericArgs: [TypeNode] = []) -> TypeNode {
        .bound(bind(genericArgs: genericArgs))
    }
}
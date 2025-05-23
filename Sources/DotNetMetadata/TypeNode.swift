/// A type as can describe a variable, parameter, or return type.
/// Types are arranged as a tree and cannot reference unbound type definitions.
public enum TypeNode: Hashable {
    case bound(BoundType)
    indirect case array(of: TypeNode, shape: ArrayShape)
    case genericParam(GenericParam)
    indirect case pointer(to: TypeNode?) // nil for void*
}

extension TypeNode {
    public var context: AssemblyLoadContext? {
        switch self {
            case .bound(let bound): return bound.context
            case .array(let element, shape: _): return element.context
            case .genericParam(let param): return param.context
            case .pointer(let pointee): return pointee?.context
        }
    }

    public static func array(of element: TypeNode) -> TypeNode {
        .array(of: element, shape: ArrayShape.vector)
    }

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
            case .genericParam(let param):
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

    public var isParameterized: Bool {
        switch self {
            case .bound(let bound): return bound.isParameterized
            case .array(let element, shape: _): return element.isParameterized
            case .genericParam: return true
            case .pointer(let element): return element?.isParameterized ?? false
        }
    }

    public func bindGenericParams(_ binding: (GenericParam) throws -> TypeNode) rethrows -> TypeNode {
        switch self {
            case .bound(let bound):
                return .bound(bound.definition, genericArgs: try bound.genericArgs.map { try $0.bindGenericParams(binding) })
            case .array(let element, shape: let shape):
                return .array(of: try element.bindGenericParams(binding), shape: shape)
            case .genericParam(let param):
                return try binding(param)
            case .pointer(let pointee):
                return .pointer(to: try pointee?.bindGenericParams(binding))
        }
    }

    public func bindGenericParams(typeArgs: [TypeNode]?, methodArgs: [TypeNode]? = nil) -> TypeNode {
        bindGenericParams { $0.bind(typeArgs: typeArgs, methodArgs: methodArgs) }
    }
}

extension TypeNode: CustomStringConvertible {
    public var description: String {
        switch self {
            case .bound(let type): return type.description
            case .array(of: let element, shape: let shape): return element.description + shape.description
            case .genericParam(let genericParam): return genericParam.name
            case .pointer(to: let pointee): return (pointee?.description ?? "void") + "*"
        }
    }
}

extension TypeDefinition {
    public func bindNode(genericArgs: [TypeNode] = []) -> TypeNode {
        .bound(bindType(genericArgs: genericArgs))
    }
}
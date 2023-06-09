public enum Type {
    case definition(BoundDefinition)
    indirect case array(element: Type)
    case genericArgument(param: GenericParam)
    indirect case pointer(element: Type)

    /// A type definition with any and all generic arguments bound.
    public struct BoundDefinition {
        public let definition: TypeDefinition
        public let genericArgs: [Type]

        public init(_ definition: TypeDefinition, genericArgs: [Type]) {
            precondition(definition.genericParams.count == genericArgs.count)
            self.definition = definition
            self.genericArgs = genericArgs
        }
    }
}

extension Type {
    public var asUnboundDefinition: TypeDefinition? {
        switch self {
            case .definition(let bound): return bound.definition
            default: return nil
        }
    }
}

extension Type: Equatable {
    public static func ==(lhs: Type, rhs: Type) -> Bool {
        switch (lhs, rhs) {
            case (.definition(let lhs), .definition(let rhs)):
                return lhs.definition === rhs.definition && lhs.genericArgs == rhs.genericArgs
            case (.array(let lhs), .array(let rhs)):
                return lhs == rhs
            case (.genericArgument(let lhs), .genericArgument(let rhs)):
                return lhs === rhs
            case (.pointer(let lhs), .pointer(let rhs)):
                return lhs == rhs
            default:
                return false
        }
    }
}

extension TypeDefinition {
    public func bind(genericArgs: [Type]) -> Type {
        .definition(.init(self, genericArgs: genericArgs))
    }

    public func bindNonGeneric() -> Type {
        .definition(.init(self, genericArgs: []))
    }
}
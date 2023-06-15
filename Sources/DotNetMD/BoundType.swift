/// A type with no unbound generic type parameters.
public enum BoundType {
    case definition(Definition)
    indirect case array(element: BoundType)
    case genericArg(param: GenericParam)
    indirect case pointer(element: BoundType)

    /// A type definition with any and all generic arguments bound.
    public struct Definition {
        public let definition: TypeDefinition
        public let genericArgs: [BoundType]

        public init(_ definition: TypeDefinition, genericArgs: [BoundType]) {
            precondition(definition.genericParams.count == genericArgs.count)
            self.definition = definition
            self.genericArgs = genericArgs
        }
    }
}

extension BoundType {
    public var asUnbound: TypeDefinition? {
        switch self {
            case .definition(let bound): return bound.definition
            default: return nil
        }
    }
}

extension BoundType: Equatable {
    public static func ==(lhs: BoundType, rhs: BoundType) -> Bool {
        switch (lhs, rhs) {
            case (.definition(let lhs), .definition(let rhs)):
                return lhs.definition === rhs.definition && lhs.genericArgs == rhs.genericArgs
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
    public func bind(genericArgs: [BoundType]) -> BoundType {
        .definition(.init(self, genericArgs: genericArgs))
    }

    public func bindNonGeneric() -> BoundType {
        .definition(.init(self, genericArgs: []))
    }
}
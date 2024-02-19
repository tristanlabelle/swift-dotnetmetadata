/// A type definition with all generic parameters specified.
/// Valid: "NonGenericType", "GenericType<ConcreteType>", "GenericType<TypeParameter>"
/// Invalid: "GenericType<>"
public struct BoundTypeOf<Definition: TypeDefinition>: Hashable {
    public let definition: Definition
    public let genericArgs: [TypeNode]

    public init(_ definition: Definition, genericArgs: [TypeNode]) {
        precondition(definition.genericArity == genericArgs.count)
        self.definition = definition
        self.genericArgs = genericArgs

        #if DEBUG
        for genericArg in genericArgs {
            if let genericArgContext = genericArg.context {
                precondition(genericArgContext === definition.context)
            }
        }
        #endif
    }

    public var context: AssemblyLoadContext { definition.context }

    public var asNode: TypeNode { .bound(.init(definition, genericArgs: genericArgs)) }
    public var isParameterized: Bool { !genericArgs.allSatisfy { !$0.isParameterized } }

    public func bindGenericParams(_ binding: (GenericParam) throws -> TypeNode) rethrows -> Self {
        .init(definition, genericArgs: try genericArgs.map { try $0.bindGenericParams(binding) })
    }

    public func bindGenericParams(typeArgs: [TypeNode]?, methodArgs: [TypeNode]? = nil) -> Self {
        bindGenericParams { $0.bind(typeArgs: typeArgs, methodArgs: methodArgs) }
    }
}

extension BoundTypeOf: CustomStringConvertible {
    public var description: String {
        var result = ""

        if let namespace = definition.namespace {
            result += namespace
            result += "."
        }

        result += definition.nameWithoutGenericSuffix

        if genericArgs.count > 0 {
            result += "<"
            for (index, genericArg) in genericArgs.enumerated() {
                if index > 0 { result += ", " }
                result += genericArg.description
            }
            result += ">"
        }

        return result
    }
}

public typealias BoundType = BoundTypeOf<TypeDefinition>
extension TypeDefinition {
    public func bindType(genericArgs: [TypeNode] = []) -> BoundType {
        .init(self, genericArgs: genericArgs)
    }
}

public typealias BoundStruct = BoundTypeOf<StructDefinition>
extension BoundStruct {
    public var asBoundType: BoundType { .init(definition, genericArgs: genericArgs) }
}

extension StructDefinition {
    public typealias Bound = BoundStruct
    public func bind(genericArgs: [TypeNode] = []) -> BoundStruct {
        .init(self, genericArgs: genericArgs)
    }
}

public typealias BoundClass = BoundTypeOf<ClassDefinition>
extension BoundClass {
    public var asBoundType: BoundType { .init(definition, genericArgs: genericArgs) }
}

extension ClassDefinition {
    public typealias Bound = BoundClass
    public func bind(genericArgs: [TypeNode] = []) -> BoundClass {
        .init(self, genericArgs: genericArgs)
    }
}

public typealias BoundInterface = BoundTypeOf<InterfaceDefinition>
extension BoundInterface {
    public var asBoundType: BoundType { .init(definition, genericArgs: genericArgs) }
}

extension InterfaceDefinition {
    public typealias Bound = BoundInterface
    public func bind(genericArgs: [TypeNode] = []) -> BoundInterface {
        .init(self, genericArgs: genericArgs)
    }
}

public typealias BoundDelegate = BoundTypeOf<DelegateDefinition>
extension BoundDelegate {
    public var asBoundType: BoundType { .init(definition, genericArgs: genericArgs) }
}

extension DelegateDefinition {
    public typealias Bound = BoundDelegate
    public func bind(genericArgs: [TypeNode] = []) -> BoundDelegate {
        .init(self, genericArgs: genericArgs)
    }
}
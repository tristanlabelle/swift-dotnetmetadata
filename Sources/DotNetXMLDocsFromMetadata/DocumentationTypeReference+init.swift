import DotNetMetadata
import DotNetXMLDocs

extension DocumentationTypeReference {
    public init(forTypeDefinition typeDefinition: TypeDefinition, genericArgs: [TypeNode]? = nil) {
        self.init(
            namespace: typeDefinition.namespace,
            nameWithoutGenericArity: typeDefinition.nameWithoutGenericArity,
            genericity: Genericity(forTypeDefinition: typeDefinition, genericArgs: genericArgs))
    }

    public init(forBoundType boundType: BoundType) {
        self.init(forTypeDefinition: boundType.definition, genericArgs: boundType.genericArgs)
    }
}

extension DocumentationTypeReference.Genericity {
    public init(forTypeDefinition typeDefinition: TypeDefinition, genericArgs: [TypeNode]?) {
        precondition(typeDefinition.genericArity == (genericArgs?.count ?? 0))
        if let genericArgs {
            self = .bound(genericArgs.map { .init(forTypeNode: $0) })
        }
        else {
            self = typeDefinition.genericArity == 0
                ? .bound([])
                : .unbound(arity: typeDefinition.genericArity)
        }
    }
}
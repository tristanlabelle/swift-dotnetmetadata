public struct DocumentationTypeReference: Hashable {
    public var namespace: String?
    public var nameWithoutGenericArity: String
    public var genericity: Genericity

    public init(namespace: String? = nil, nameWithoutGenericArity: String, genericity: Genericity = .bound([])) {
        self.namespace = namespace
        self.nameWithoutGenericArity = nameWithoutGenericArity
        self.genericity = genericity
    }

    public init(namespace: String? = nil, nameWithoutGenericArity: String, genericArity: Int) {
        self.init(
            namespace: namespace,
            nameWithoutGenericArity: nameWithoutGenericArity,
            genericity: genericArity == 0 ? .bound([]) : .unbound(arity: genericArity))
    }

    public init(namespace: String? = nil, nameWithoutGenericArity: String, genericArgs: [DocumentationTypeNode]) {
        self.init(
            namespace: namespace,
            nameWithoutGenericArity: nameWithoutGenericArity,
            genericity: .bound(genericArgs))
    }

    public var genericArity: Int {
        switch genericity {
            case .unbound(let arity): return arity
            case .bound(let args): return args.count
        }
    }

    public enum Genericity: Hashable {
        case unbound(arity: Int) // System.Action`1, arity should not be zero
        case bound([DocumentationTypeNode]) // System.String or System.Action`1{System.String}
    }
}
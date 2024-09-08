public enum MemberDocumentationKey: Hashable {
    public static let constructorName: String = "#ctor"

    case namespace(name: String)
    case type(DocumentationTypeReference)
    case field(declaringType: DocumentationTypeReference, name: String)
    case method(declaringType: DocumentationTypeReference, name: String, params: [Param] = [], conversionTarget: Param? = nil)
    case property(declaringType: DocumentationTypeReference, name: String, params: [Param] = [])
    case event(declaringType: DocumentationTypeReference, name: String)
    case unresolved(String)

    public struct Param: Hashable {
        public var isByRef: Bool
        public var type: DocumentationTypeNode
        public var customModifiers: [DocumentationTypeNode]

        public init(type: DocumentationTypeNode, isByRef: Bool = false, customModifiers: [DocumentationTypeNode] = []) {
            self.type = type
            self.isByRef = isByRef
            self.customModifiers = customModifiers
        }
    }
}

extension MemberDocumentationKey {
    public static func type(
            namespace: String? = nil,
            nameWithoutGenericArity: String,
            genericity: DocumentationTypeReference.Genericity = .bound([])) -> Self {
        .type(DocumentationTypeReference(
            namespace: namespace,
            nameWithoutGenericArity: nameWithoutGenericArity,
            genericity: genericity))
    }
}
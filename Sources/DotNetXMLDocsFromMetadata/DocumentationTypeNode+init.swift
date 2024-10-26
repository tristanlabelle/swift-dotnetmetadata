import DotNetMetadata
import DotNetXMLDocs

extension DocumentationTypeNode {
    public init(forTypeNode typeNode: TypeNode) {
        switch typeNode {
            case .bound(let boundType):
                self = .bound(DocumentationTypeReference(forBoundType: boundType))
            case .array(of: let elementType):
                self = .array(of: Self(forTypeNode: elementType))
            case .pointer(to: let pointeeType):
                self = .pointer(to: Self(forTypeNode: pointeeType!)) // TODO: Handle void*
            case .genericParam(let param):
                self = .genericParam(index: param.index, kind: param is GenericTypeParam ? .type : .method)
        }
    }
}
import DotNetMetadata
import DotNetXMLDocs

extension MemberDocumentationKey {
    public init(forTypeDefinition typeDefinition: TypeDefinition) {
        self = .type(DocumentationTypeReference(forTypeDefinition: typeDefinition))
    }

    public init(forMember member: Member) throws {
        let declaringType = DocumentationTypeReference(forTypeDefinition: member.definingType)
        switch member {
            case let field as Field:
                self = .field(declaringType: declaringType, name: field.name)
            case let event as Event:
                self = .event(declaringType: declaringType, name: event.name)
            case let property as Property:
                assert((try? property.getter?.arity ?? 0) == 0, "Indexers not implemented")
                self = .property(declaringType: declaringType, name: property.name)
            case let method as Method:
                let memberName = method is Constructor ? "#ctor" : method.name
                self = try .method(declaringType: declaringType, name: memberName,
                    params: method.params.map { try .init(forParam: $0) } )
            default:
                fatalError("Unexpected member type")
        }
    }
}

extension MemberDocumentationKey.Param {
    public init(forParam param: DotNetMetadata.Param) throws {
        try self.init(type: DocumentationTypeNode(forTypeNode: param.type), isByRef: param.isByRef)
    }
}
import DotNetMetadata
import DotNetXMLDocs

extension AssemblyDocumentation {
    public func lookup(typeDefinition: TypeDefinition) -> MemberDocumentation? {
        members[MemberDocumentationKey(forTypeDefinition: typeDefinition)]
    }

    public func lookup(member: Member) throws -> MemberDocumentation? {
        members[try MemberDocumentationKey(forMember: member)]
    }
}
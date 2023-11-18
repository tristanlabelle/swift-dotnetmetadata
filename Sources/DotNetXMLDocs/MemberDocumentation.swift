public struct MemberDocumentation {
    /// The <summary> tag should be used to describe a type or a type member.
    public var summary: DocumentationTextNode?

    /// The <remarks> tag is used to add information about a type or a type member,
    /// supplementing the information specified with <summary>.
    public var remarks: DocumentationTextNode?

    /// The <value> tag lets you describe the value that a property represents.
    public var value: DocumentationTextNode?

    /// The <typeparam> tag should be used in the comment for a generic type or method declaration to describe a type parameter.
    public var typeParams: [Param] = []

    /// The <param> tag should be used in the comment for a method declaration to describe one of the parameters for the method.
    public var params: [Param] = []

    /// The <returns> tag should be used in the comment for a method declaration to describe the return value.
    public var returns: DocumentationTextNode?

    /// This tag provides a way to document the exceptions a method can throw.
    public var exceptions: [Exception] = []

    public init() {}

    public struct Param: Equatable {
        public var name: String
        public var description: DocumentationTextNode

        public init(name: String, description: DocumentationTextNode) {
            self.name = name
            self.description = description
        }
    }

    public struct Exception: Equatable {
        public var type: MemberDocumentationKey
        public var description: DocumentationTextNode

        public init(type: MemberDocumentationKey, description: DocumentationTextNode) {
            self.type = type
            self.description = description
        }
    }
}
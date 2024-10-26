public struct MemberDocumentation {
    /// The <summary> tag should be used to describe a type or a type member.
    public var summary: DocumentationText?

    /// The <remarks> tag is used to add information about a type or a type member,
    /// supplementing the information specified with <summary>.
    public var remarks: DocumentationText?

    /// The <value> tag lets you describe the value that a property represents.
    public var value: DocumentationText?

    /// The <typeparam> tag should be used in the comment for a generic type or method declaration to describe a type parameter.
    public var typeParams: [Param] = []

    /// The <param> tag should be used in the comment for a method declaration to describe one of the parameters for the method.
    public var params: [Param] = []

    /// The <returns> tag should be used in the comment for a method declaration to describe the return value.
    public var returns: DocumentationText?

    /// This tag provides a way to document the exceptions a method can throw.
    public var exceptions: [Exception] = []

    public init() {}

    public struct Param: Equatable {
        public var name: String
        public var description: DocumentationText

        public init(name: String, description: DocumentationText) {
            self.name = name
            self.description = description
        }
    }

    public struct Exception: Equatable {
        public var type: DocumentationTypeReference
        public var description: DocumentationText

        public init(type: DocumentationTypeReference, description: DocumentationText) {
            self.type = type
            self.description = description
        }
    }
}
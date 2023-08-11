public struct MemberEntry {
    /// The <summary> tag should be used to describe a type or a type member.
    public var summary: TextNode?

    /// The <remarks> tag is used to add information about a type or a type member,
    /// supplementing the information specified with <summary>.
    public var remarks: TextNode?

    /// The <value> tag lets you describe the value that a property represents.
    public var value: TextNode?

    /// The <typeparam> tag should be used in the comment for a generic type or method declaration to describe a type parameter.
    public var typeParams: [String: TextNode] = [:]

    /// The <param> tag should be used in the comment for a method declaration to describe one of the parameters for the method.
    public var params: [String: TextNode] = [:]

    /// The <returns> tag should be used in the comment for a method declaration to describe the return value.
    public var returns: TextNode?

    // <exception>
}
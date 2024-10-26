import struct Foundation.URL

/// A structured documentation text.
public struct DocumentationText: Equatable {
    public var nodes: [Node]

    public init(nodes: [Node]) {
        self.nodes = nodes
    }

    public static func plain(_ text: String) -> DocumentationText {
        .init(nodes: [.plain(text)])
    }

    /// A structural node in a documentation text, roughly corresponding to an XML element.
    public enum Node: Equatable {
        // Logically there are two levels of nodes: blocks and inline,
        // but the XML nesting for doc comments is weakly defined, so we are permissive (e.g. a list can contain a paragraph).

        case plain(String)

        // Blocks
        case paragraph(DocumentationText) // <para></para>
        case list(type: ListType? = nil, items: [DocumentationText]) // <list><item></item></list>
        case codeBlock(String) // <code></code>
        case example(DocumentationText) // <example></example>

        // Inlines
        case codeSpan(text: String) // <c></c>
        case paramReference(name: String) // <paramref name=""/>
        case typeParamReference(name: String) // <typeparamref name=""/>
        case see(codeReference: MemberDocumentationKey, url: URL? = nil, also: Bool = false) // <see[also] cref="" url=""/>

        public enum ListType: String, Equatable {
            case bullet
            case number
            // case table // Not supported
        }
    }
}


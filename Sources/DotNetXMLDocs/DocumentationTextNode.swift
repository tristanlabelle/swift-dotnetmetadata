import struct Foundation.URL

public enum DocumentationTextNode: Hashable {
    case plain(String)
    case sequence([DocumentationTextNode])

    // Block formatting
    indirect case paragraph(DocumentationTextNode) // <para></para>
    case list(items: [DocumentationTextNode]) // <list><item></item></list>
    case codeBlock(String) // <code></code>
    indirect case example(DocumentationTextNode) // <example></example>

    // Inline formatting
    case codeSpan(text: String) // <c></c>
    case paramReference(name: String) // <paramref name=""/>
    case typeParamReference(name: String) // <typeparamref name=""/>
    case see(codeReference: MemberDocumentationKey, url: URL? = nil, also: Bool = false) // <see[also] cref="" url=""/>
}
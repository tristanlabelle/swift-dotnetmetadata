import struct Foundation.URL

public enum TextNode: Hashable {
    case plain(String)
    case sequence([TextNode])

    // Block formatting
    indirect case paragraph(TextNode) // <para></para>
    case list(items: [TextNode]) // <list><item></item></list>
    case codeBlock(String) // <code></code>
    indirect case example(TextNode) // <example></example>

    // Inline formatting
    case codeSpan(text: String) // <c></c>
    case paramReference(name: String) // <paramref name=""/>
    case typeParamReference(name: String) // <typeparamref name=""/>
    case see(codeReference: MemberKey, url: URL? = nil, also: Bool = false) // <see[also] cref="" url=""/>
}
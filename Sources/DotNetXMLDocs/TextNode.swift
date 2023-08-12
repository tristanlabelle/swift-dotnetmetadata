public enum TextNode: Hashable {
    case plain(String)
    case sequence([TextNode])
    case list(items: [TextNode])
}
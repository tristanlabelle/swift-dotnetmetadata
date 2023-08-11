public enum TextNode {
    case string(String)
    case sequence([TextNode])
}
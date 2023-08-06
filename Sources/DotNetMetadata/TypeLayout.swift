import DotNetMetadataFormat

public enum TypeLayout: Hashable {
    case auto
    case sequential(pack: Int?, minSize: Int)
    case explicit(minSize: Int)
}
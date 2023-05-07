protocol CodedIndex {
    static var tables: [MetadataTokenKind?] { get }
    static func create(database: Database, tag: Int, index: Int) -> Self
}

public enum ResolutionScope : CodedIndex {
    case null
    case module(RecordRef<Module>)

    static let tables: [MetadataTokenKind?] = [ .module, .moduleRef, .assemblyRef, .typeRef ]
    static func create(database: Database, tag: Int, index: Int) -> Self {
        switch tag {
            case 0: return .null
            case 1: return .module(RecordRef(table: database.modules, index: index))
            default: fatalError()
        }
    }
}
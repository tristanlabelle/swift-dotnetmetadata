protocol CodedIndex {
    static var tables: [TableIndex?] { get }
    static func create(database: Database, tag: Int, index: Int) -> Self
}

public enum ResolutionScope : CodedIndex {
    case module(TableRowRef<Module>?)
    case moduleRef
    case assemblyRef
    case typeRef(TableRowRef<TypeRef>?)

    static let tables: [TableIndex?] = [ .module, .moduleRef, .assemblyRef, .typeRef ]
    static func create(database: Database, tag: Int, index: Int) -> Self {
        switch tag {
            case 1: return .module(TableRowRef(table: database.moduleTable, index: index))
            default: fatalError()
        }
    }
}

public enum TypeDefOrRef : CodedIndex {
    case typeDef(TableRowRef<TypeDef>?)
    case typeRef(TableRowRef<TypeRef>?)
    case typeSpec

    static let tables: [TableIndex?] = [ .typeDef, .typeRef, .typeSpec ]
    static func create(database: Database, tag: Int, index: Int) -> Self {
        switch tag {
            default: fatalError()
        }
    }
}
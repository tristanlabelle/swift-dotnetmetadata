public protocol CodedIndex {
    static var tables: [TableIndex?] { get }
    static func create(tag: UInt8, index: UInt32) -> Self
}

public enum ResolutionScope : CodedIndex {
    case module(TableRow<Module>)
    case moduleRef
    case assemblyRef
    case typeRef(TableRow<TypeRef>)

    public static let tables: [TableIndex?] = [ .module, .moduleRef, .assemblyRef, .typeRef ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .module(TableRow(index))
            default: fatalError()
        }
    }
}

public enum TypeDefOrRef : CodedIndex {
    case typeDef(TableRow<TypeDef>)
    case typeRef(TableRow<TypeRef>)
    case typeSpec

    public static let tables: [TableIndex?] = [ .typeDef, .typeRef, .typeSpec ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .typeDef(TableRow(index))
            case 1: return .typeRef(TableRow(index))
            default: fatalError()
        }
    }
}
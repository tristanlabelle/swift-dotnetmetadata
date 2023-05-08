public protocol CodedIndex {
    static var tables: [TableIndex?] { get }
    static func create(tag: UInt8, index: UInt32) -> Self
}

public enum ResolutionScope : CodedIndex {
    case module(RowIndex<Module>)
    case moduleRef
    case assemblyRef
    case typeRef(RowIndex<TypeRef>)

    public static let tables: [TableIndex?] = [ .module, .moduleRef, .assemblyRef, .typeRef ]
    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .module(RowIndex(index))
            default: fatalError()
        }
    }
}

public enum TypeDefOrRef : CodedIndex {
    case typeDef(RowIndex<TypeDef>)
    case typeRef(RowIndex<TypeRef>)
    case typeSpec

    public static let tables: [TableIndex?] = [ .typeDef, .typeRef, .typeSpec ]
    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .typeDef(RowIndex(index))
            case 1: return .typeRef(RowIndex(index))
            default: fatalError()
        }
    }
}
public protocol CodedIndex {
    static var tables: [TableIndex?] { get }
    static func create(tag: UInt8, index: UInt32) -> Self
}

public enum HasConstant : CodedIndex {
    case field
    case param(TableRow<Param>)
    case property

    public static let tables: [TableIndex?] = [ .field, .param, .property ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 1: return .param(TableRow(index))
            default: fatalError()
        }
    }
}

public enum MemberRefParent : CodedIndex {
    case typeDef(TableRow<TypeDef>)
    case typeRef(TableRow<TypeRef>)
    case moduleRef
    case methodDef(TableRow<MethodDef>)
    case typeSpec

    public static let tables: [TableIndex?] = [ .typeDef, .typeRef, .moduleRef, .methodDef, .typeSpec ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .typeDef(TableRow(index))
            case 1: return .typeRef(TableRow(index))
            case 3: return .methodDef(TableRow(index))
            default: fatalError()
        }
    }
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
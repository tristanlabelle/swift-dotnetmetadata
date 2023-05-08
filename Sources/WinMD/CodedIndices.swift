public protocol CodedIndex {
    static var tables: [TableIndex?] { get }
    static func create(tag: UInt8, index: UInt32) -> Self
}

public enum CustomAttributeType : CodedIndex {
    case methodDef(TableRow<MethodDef>)
    case memberRef(TableRow<MemberRef>)

    public static let tables: [TableIndex?] = [ nil, nil, .methodDef, .memberRef, nil ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 2: return .methodDef(TableRow(index))
            case 3: return .memberRef(TableRow(index))
            default: fatalError()
        }
    }
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

public enum HasSemantics : CodedIndex {
    case event(TableRow<Event>)
    case property(TableRow<Property>)

    public static let tables: [TableIndex?] = [ .event, .property ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .event(TableRow(index))
            case 1: return .property(TableRow(index))
            default: fatalError()
        }
    }
}

public enum HasCustomAttribute : CodedIndex {
    case methodDef(TableRow<MethodDef>)
    case field(TableRow<Field>)
    case typeRef(TableRow<TypeRef>)
    case typeDef(TableRow<TypeDef>)
    case param(TableRow<Param>)
    case interfaceImpl(TableRow<InterfaceImpl>)
    case memberRef(TableRow<MemberRef>)
    case module(TableRow<Module>)
    case permission
    case property
    case event
    case standAloneSig
    case moduleRef
    case typeSpec
    case assembly(TableRow<Assembly>)
    case assemblyRef
    case file
    case exportedType
    case manifestResource

    public static let tables: [TableIndex?] = [
        .methodDef, .field, .typeRef, .typeDef, .param, .interfaceImpl,
        .memberRef, .module, nil /* .permission */, .property, .event, .standAloneSig,
        .moduleRef, .typeSpec, .assembly, .assemblyRef, .file, .exportedType,
        .manifestResource
    ]

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

public enum MethodDefOrRef : CodedIndex {
    case methodDef(TableRow<MethodDef>)
    case memberRef(TableRow<MemberRef>)

    public static let tables: [TableIndex?] = [ .methodDef, .memberRef ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .methodDef(TableRow(index))
            case 1: return .memberRef(TableRow(index))
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
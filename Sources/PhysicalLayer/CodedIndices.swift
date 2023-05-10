public protocol CodedIndex {
    static var tables: [TableIndex?] { get }
    static func create(tag: UInt8, index: UInt32) -> Self
}

public enum CustomAttributeType : CodedIndex {
    case methodDef(TableRowIndex<MethodDef>)
    case memberRef(TableRowIndex<MemberRef>)

    public static let tables: [TableIndex?] = [ nil, nil, .methodDef, .memberRef, nil ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 2: return .methodDef(TableRowIndex(index))
            case 3: return .memberRef(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum HasConstant : CodedIndex {
    case field(TableRowIndex<Field>)
    case param(TableRowIndex<Param>)
    case property(TableRowIndex<Property>)

    public static let tables: [TableIndex?] = [ .field, .param, .property ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .field(TableRowIndex(index))
            case 1: return .param(TableRowIndex(index))
            case 2: return .property(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum HasSemantics : CodedIndex {
    case event(TableRowIndex<Event>)
    case property(TableRowIndex<Property>)

    public static let tables: [TableIndex?] = [ .event, .property ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .event(TableRowIndex(index))
            case 1: return .property(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum HasCustomAttribute : CodedIndex {
    case methodDef(TableRowIndex<MethodDef>)
    case field(TableRowIndex<Field>)
    case typeRef(TableRowIndex<TypeRef>)
    case typeDef(TableRowIndex<TypeDef>)
    case param(TableRowIndex<Param>)
    case interfaceImpl(TableRowIndex<InterfaceImpl>)
    case memberRef(TableRowIndex<MemberRef>)
    case module(TableRowIndex<Module>)
    case permission
    case property(TableRowIndex<Property>)
    case event(TableRowIndex<Event>)
    case standAloneSig
    case moduleRef
    case typeSpec(TableRowIndex<TypeSpec>)
    case assembly(TableRowIndex<Assembly>)
    case assemblyRef(TableRowIndex<AssemblyRef>)
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
            case 0: return .methodDef(TableRowIndex(index))
            case 1: return .field(TableRowIndex(index))
            case 2: return .typeRef(TableRowIndex(index))
            case 3: return .typeDef(TableRowIndex(index))
            case 4: return .param(TableRowIndex(index))
            case 5: return .interfaceImpl(TableRowIndex(index))
            case 6: return .memberRef(TableRowIndex(index))
            case 7: return .module(TableRowIndex(index))
            case 9: return .property(TableRowIndex(index))
            case 10: return .event(TableRowIndex(index))
            case 13: return .typeSpec(TableRowIndex(index))
            case 14: return .assembly(TableRowIndex(index))
            case 15: return .assemblyRef(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum MemberRefParent : CodedIndex {
    case typeDef(TableRowIndex<TypeDef>)
    case typeRef(TableRowIndex<TypeRef>)
    case moduleRef
    case methodDef(TableRowIndex<MethodDef>)
    case typeSpec(TableRowIndex<TypeSpec>)

    public static let tables: [TableIndex?] = [ .typeDef, .typeRef, .moduleRef, .methodDef, .typeSpec ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .typeDef(TableRowIndex(index))
            case 1: return .typeRef(TableRowIndex(index))
            case 3: return .methodDef(TableRowIndex(index))
            case 4: return .typeSpec(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum MethodDefOrRef : CodedIndex {
    case methodDef(TableRowIndex<MethodDef>)
    case memberRef(TableRowIndex<MemberRef>)

    public static let tables: [TableIndex?] = [ .methodDef, .memberRef ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .methodDef(TableRowIndex(index))
            case 1: return .memberRef(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum ResolutionScope : CodedIndex {
    case module(TableRowIndex<Module>)
    case moduleRef
    case assemblyRef(TableRowIndex<AssemblyRef>)
    case typeRef(TableRowIndex<TypeRef>)

    public static let tables: [TableIndex?] = [ .module, .moduleRef, .assemblyRef, .typeRef ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .module(TableRowIndex(index))
            case 2: return .assemblyRef(TableRowIndex(index))
            case 3: return .typeRef(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum TypeDefOrRef : CodedIndex {
    case typeDef(TableRowIndex<TypeDef>)
    case typeRef(TableRowIndex<TypeRef>)
    case typeSpec(TableRowIndex<TypeSpec>)

    public static let tables: [TableIndex?] = [ .typeDef, .typeRef, .typeSpec ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .typeDef(TableRowIndex(index))
            case 1: return .typeRef(TableRowIndex(index))
            case 2: return .typeSpec(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum TypeOrMethodDef: CodedIndex {
    case typeDef(TableRowIndex<TypeDef>)
    case methodDef(TableRowIndex<MethodDef>)

    public static let tables: [TableIndex?] = [ .typeDef, .methodDef ]

    public static func create(tag: UInt8, index: UInt32) -> Self {
        switch tag {
            case 0: return .typeDef(TableRowIndex(index))
            case 1: return .methodDef(TableRowIndex(index))
            default: fatalError()
        }
    }
}
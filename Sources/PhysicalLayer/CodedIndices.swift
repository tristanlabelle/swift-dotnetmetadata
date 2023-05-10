public protocol CodedIndex {
    static var tables: [TableIndex?] { get }
    init(tag: UInt8, index: UInt32)
}

public enum CustomAttributeType : CodedIndex {
    case methodDef(TableRowIndex<MethodDef>)
    case memberRef(TableRowIndex<MemberRef>)

    public static let tables: [TableIndex?] = [ nil, nil, .methodDef, .memberRef, nil ]

    public init(tag: UInt8, index: UInt32) {
        switch tag {
            case 2: self = .methodDef(TableRowIndex(index))
            case 3: self = .memberRef(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum HasConstant : CodedIndex {
    case field(TableRowIndex<Field>)
    case param(TableRowIndex<Param>)
    case property(TableRowIndex<Property>)

    public static let tables: [TableIndex?] = [ .field, .param, .property ]

    public init(tag: UInt8, index: UInt32) {
        switch tag {
            case 0: self = .field(TableRowIndex(index))
            case 1: self = .param(TableRowIndex(index))
            case 2: self = .property(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum HasSemantics : CodedIndex {
    case event(TableRowIndex<Event>)
    case property(TableRowIndex<Property>)

    public static let tables: [TableIndex?] = [ .event, .property ]

    public init(tag: UInt8, index: UInt32) {
        switch tag {
            case 0: self = .event(TableRowIndex(index))
            case 1: self = .property(TableRowIndex(index))
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

    public init(tag: UInt8, index: UInt32) {
        switch tag {
            case 0: self = .methodDef(TableRowIndex(index))
            case 1: self = .field(TableRowIndex(index))
            case 2: self = .typeRef(TableRowIndex(index))
            case 3: self = .typeDef(TableRowIndex(index))
            case 4: self = .param(TableRowIndex(index))
            case 5: self = .interfaceImpl(TableRowIndex(index))
            case 6: self = .memberRef(TableRowIndex(index))
            case 7: self = .module(TableRowIndex(index))
            case 9: self = .property(TableRowIndex(index))
            case 10: self = .event(TableRowIndex(index))
            case 13: self = .typeSpec(TableRowIndex(index))
            case 14: self = .assembly(TableRowIndex(index))
            case 15: self = .assemblyRef(TableRowIndex(index))
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

    public init(tag: UInt8, index: UInt32) {
        switch tag {
            case 0: self = .typeDef(TableRowIndex(index))
            case 1: self = .typeRef(TableRowIndex(index))
            case 3: self = .methodDef(TableRowIndex(index))
            case 4: self = .typeSpec(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum MethodDefOrRef : CodedIndex {
    case methodDef(TableRowIndex<MethodDef>)
    case memberRef(TableRowIndex<MemberRef>)

    public static let tables: [TableIndex?] = [ .methodDef, .memberRef ]

    public init(tag: UInt8, index: UInt32) {
        switch tag {
            case 0: self = .methodDef(TableRowIndex(index))
            case 1: self = .memberRef(TableRowIndex(index))
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

    public init(tag: UInt8, index: UInt32) {
        switch tag {
            case 0: self = .module(TableRowIndex(index))
            case 2: self = .assemblyRef(TableRowIndex(index))
            case 3: self = .typeRef(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum TypeDefOrRef : CodedIndex {
    case typeDef(TableRowIndex<TypeDef>)
    case typeRef(TableRowIndex<TypeRef>)
    case typeSpec(TableRowIndex<TypeSpec>)

    public static let tables: [TableIndex?] = [ .typeDef, .typeRef, .typeSpec ]

    public init(tag: UInt8, index: UInt32) {
        switch tag {
            case 0: self = .typeDef(TableRowIndex(index))
            case 1: self = .typeRef(TableRowIndex(index))
            case 2: self = .typeSpec(TableRowIndex(index))
            default: fatalError()
        }
    }
}

public enum TypeOrMethodDef: CodedIndex {
    case typeDef(TableRowIndex<TypeDef>)
    case methodDef(TableRowIndex<MethodDef>)

    public static let tables: [TableIndex?] = [ .typeDef, .methodDef ]

    public init(tag: UInt8, index: UInt32) {
        switch tag {
            case 0: self = .typeDef(TableRowIndex(index))
            case 1: self = .methodDef(TableRowIndex(index))
            default: fatalError()
        }
    }
}
public protocol CodedIndex {
    static var tables: [TableIndex?] { get }
    init(tag: UInt8, oneBasedIndex: UInt32)
}

extension CodedIndex {
    public static var tagBitCount: Int { Int.bitWidth - (tables.count - 1).leadingZeroBitCount }
}

public enum CustomAttributeType : CodedIndex {
    case methodDef(TableRowIndex<MethodDef>)
    case memberRef(TableRowIndex<MemberRef>)

    public static let tables: [TableIndex?] = [ nil, nil, .methodDef, .memberRef, nil ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 2: self = .methodDef(.init(oneBased: oneBasedIndex))
            case 3: self = .memberRef(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }
}

public enum HasConstant : CodedIndex {
    case field(TableRowIndex<Field>)
    case param(TableRowIndex<Param>)
    case property(TableRowIndex<Property>)

    public static let tables: [TableIndex?] = [ .field, .param, .property ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .field(.init(oneBased: oneBasedIndex))
            case 1: self = .param(.init(oneBased: oneBasedIndex))
            case 2: self = .property(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }
}

public enum HasSemantics : CodedIndex {
    case event(TableRowIndex<Event>)
    case property(TableRowIndex<Property>)

    public static let tables: [TableIndex?] = [ .event, .property ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .event(.init(oneBased: oneBasedIndex))
            case 1: self = .property(.init(oneBased: oneBasedIndex))
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

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .methodDef(.init(oneBased: oneBasedIndex))
            case 1: self = .field(.init(oneBased: oneBasedIndex))
            case 2: self = .typeRef(.init(oneBased: oneBasedIndex))
            case 3: self = .typeDef(.init(oneBased: oneBasedIndex))
            case 4: self = .param(.init(oneBased: oneBasedIndex))
            case 5: self = .interfaceImpl(.init(oneBased: oneBasedIndex))
            case 6: self = .memberRef(.init(oneBased: oneBasedIndex))
            case 7: self = .module(.init(oneBased: oneBasedIndex))
            case 9: self = .property(.init(oneBased: oneBasedIndex))
            case 10: self = .event(.init(oneBased: oneBasedIndex))
            case 13: self = .typeSpec(.init(oneBased: oneBasedIndex))
            case 14: self = .assembly(.init(oneBased: oneBasedIndex))
            case 15: self = .assemblyRef(.init(oneBased: oneBasedIndex))
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

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .typeDef(.init(oneBased: oneBasedIndex))
            case 1: self = .typeRef(.init(oneBased: oneBasedIndex))
            case 3: self = .methodDef(.init(oneBased: oneBasedIndex))
            case 4: self = .typeSpec(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }
}

public enum MethodDefOrRef : CodedIndex {
    case methodDef(TableRowIndex<MethodDef>)
    case memberRef(TableRowIndex<MemberRef>)

    public static let tables: [TableIndex?] = [ .methodDef, .memberRef ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .methodDef(.init(oneBased: oneBasedIndex))
            case 1: self = .memberRef(.init(oneBased: oneBasedIndex))
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

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .module(.init(oneBased: oneBasedIndex))
            case 2: self = .assemblyRef(.init(oneBased: oneBasedIndex))
            case 3: self = .typeRef(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }
}

public enum TypeDefOrRef : CodedIndex {
    case typeDef(TableRowIndex<TypeDef>)
    case typeRef(TableRowIndex<TypeRef>)
    case typeSpec(TableRowIndex<TypeSpec>)

    public static let tables: [TableIndex?] = [ .typeDef, .typeRef, .typeSpec ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .typeDef(.init(oneBased: oneBasedIndex))
            case 1: self = .typeRef(.init(oneBased: oneBasedIndex))
            case 2: self = .typeSpec(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }
}

public enum TypeOrMethodDef: CodedIndex {
    case typeDef(TableRowIndex<TypeDef>)
    case methodDef(TableRowIndex<MethodDef>)

    public static let tables: [TableIndex?] = [ .typeDef, .methodDef ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .typeDef(.init(oneBased: oneBasedIndex))
            case 1: self = .methodDef(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }
}
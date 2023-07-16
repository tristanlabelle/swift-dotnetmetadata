public protocol CodedIndex: Hashable {
    static var tables: [TableID?] { get }
    init(tag: UInt8, oneBasedIndex: UInt32)
    var metadataToken: MetadataToken { get }
}

extension CodedIndex {
    public static var tagBitCount: Int { Int.bitWidth - (tables.count - 1).leadingZeroBitCount }
}

public enum CustomAttributeType: CodedIndex {
    case methodDef(MethodDefTable.RowIndex?)
    case memberRef(MemberRefTable.RowIndex?)

    public static let tables: [TableID?] = [ nil, nil, .methodDef, .memberRef, nil ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 2: self = .methodDef(.init(oneBased: oneBasedIndex))
            case 3: self = .memberRef(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .methodDef(rowIndex): return .init(rowIndex)
            case let .memberRef(rowIndex): return .init(rowIndex)
        }
    }
}

public enum HasConstant: CodedIndex {
    case field(FieldTable.RowIndex?)
    case param(ParamTable.RowIndex?)
    case property(PropertyTable.RowIndex?)

    public static let tables: [TableID?] = [ .field, .param, .property ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .field(.init(oneBased: oneBasedIndex))
            case 1: self = .param(.init(oneBased: oneBasedIndex))
            case 2: self = .property(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .field(rowIndex): return .init(rowIndex)
            case let .param(rowIndex): return .init(rowIndex)
            case let .property(rowIndex): return .init(rowIndex)
        }
    }
}

public enum HasDeclSecurity: CodedIndex {
    case typeDef(TypeDefTable.RowIndex?)
    case methodDef(MethodDefTable.RowIndex?)
    case assembly(AssemblyTable.RowIndex?)

    public static let tables: [TableID?] = [ .typeDef, .methodDef, .assembly ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .typeDef(.init(oneBased: oneBasedIndex))
            case 1: self = .methodDef(.init(oneBased: oneBasedIndex))
            case 2: self = .assembly(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .typeDef(rowIndex): return .init(rowIndex)
            case let .methodDef(rowIndex): return .init(rowIndex)
            case let .assembly(rowIndex): return .init(rowIndex)
        }
    }
}

public enum HasFieldMarshal: CodedIndex {
    case field(FieldTable.RowIndex?)
    case param(ParamTable.RowIndex?)

    public static let tables: [TableID?] = [ .field, .param ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .field(.init(oneBased: oneBasedIndex))
            case 1: self = .param(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .field(rowIndex): return .init(rowIndex)
            case let .param(rowIndex): return .init(rowIndex)
        }
    }
}

public enum HasSemantics: CodedIndex {
    case event(EventTable.RowIndex?)
    case property(PropertyTable.RowIndex?)

    public static let tables: [TableID?] = [ .event, .property ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .event(.init(oneBased: oneBasedIndex))
            case 1: self = .property(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .event(rowIndex): return .init(rowIndex)
            case let .property(rowIndex): return .init(rowIndex)
        }
    }
}

public enum HasCustomAttribute: CodedIndex {
    case methodDef(MethodDefTable.RowIndex?)
    case field(FieldTable.RowIndex?)
    case typeRef(TypeRefTable.RowIndex?)
    case typeDef(TypeDefTable.RowIndex?)
    case param(ParamTable.RowIndex?)
    case interfaceImpl(InterfaceImplTable.RowIndex?)
    case memberRef(MemberRefTable.RowIndex?)
    case module(ModuleTable.RowIndex?)
    case declSecurity(DeclSecurityTable.RowIndex?)
    case property(PropertyTable.RowIndex?)
    case event(EventTable.RowIndex?)
    case standAloneSig(StandAloneSigTable.RowIndex?)
    case moduleRef(ModuleRefTable.RowIndex?)
    case typeSpec(TypeSpecTable.RowIndex?)
    case assembly(AssemblyTable.RowIndex?)
    case assemblyRef(AssemblyRefTable.RowIndex?)
    case file(FileTable.RowIndex?)
    case exportedType(oneBasedIndex: UInt32)
    case manifestResource(ManifestResourceTable.RowIndex?)

    public static let tables: [TableID?] = [
        .methodDef, .field, .typeRef, .typeDef, .param, .interfaceImpl,
        .memberRef, .module, .declSecurity, .property, .event, .standAloneSig,
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
            case 8: self = .declSecurity(.init(oneBased: oneBasedIndex))
            case 9: self = .property(.init(oneBased: oneBasedIndex))
            case 10: self = .event(.init(oneBased: oneBasedIndex))
            case 11: self = .standAloneSig(.init(oneBased: oneBasedIndex))
            case 12: self = .moduleRef(.init(oneBased: oneBasedIndex))
            case 13: self = .typeSpec(.init(oneBased: oneBasedIndex))
            case 14: self = .assembly(.init(oneBased: oneBasedIndex))
            case 15: self = .assemblyRef(.init(oneBased: oneBasedIndex))
            case 16: self = .file(.init(oneBased: oneBasedIndex))
            case 17: self = .exportedType(oneBasedIndex: oneBasedIndex)
            case 18: self = .manifestResource(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .methodDef(rowIndex): return .init(rowIndex)
            case let .field(rowIndex): return .init(rowIndex)
            case let .typeRef(rowIndex): return .init(rowIndex)
            case let .typeDef(rowIndex): return .init(rowIndex)
            case let .param(rowIndex): return .init(rowIndex)
            case let .interfaceImpl(rowIndex): return .init(rowIndex)
            case let .memberRef(rowIndex): return .init(rowIndex)
            case let .module(rowIndex): return .init(rowIndex)
            case let .declSecurity(rowIndex): return .init(rowIndex)
            case let .property(rowIndex): return .init(rowIndex)
            case let .event(rowIndex): return .init(rowIndex)
            case let .standAloneSig(rowIndex): return .init(rowIndex)
            case let .moduleRef(rowIndex): return .init(rowIndex)
            case let .typeSpec(rowIndex): return .init(rowIndex)
            case let .assembly(rowIndex): return .init(rowIndex)
            case let .assemblyRef(rowIndex): return .init(rowIndex)
            case let .file(rowIndex): return .init(rowIndex)
            case let .exportedType(oneBasedRowIndex): return .init(tableID: .exportedType, oneBasedRowIndex: oneBasedRowIndex)
            case let .manifestResource(rowIndex): return .init(rowIndex)
        }
    }
}

public enum Implementation: CodedIndex {
    case file(FileTable.RowIndex?)
    case assemblyRef(AssemblyRefTable.RowIndex?)
    case exportedType(oneBasedIndex: UInt32)

    public static let tables: [TableID?] = [ .file, .assemblyRef, .exportedType ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .file(.init(oneBased: oneBasedIndex))
            case 1: self = .assemblyRef(.init(oneBased: oneBasedIndex))
            case 2: self = .exportedType(oneBasedIndex: oneBasedIndex)
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .file(rowIndex): return .init(rowIndex)
            case let .assemblyRef(rowIndex): return .init(rowIndex)
            case let .exportedType(oneBasedRowIndex): return .init(tableID: .exportedType, oneBasedRowIndex: oneBasedRowIndex)
        }
    }
}

public enum MemberForwarded: CodedIndex {
    case field(FieldTable.RowIndex?)
    case methodDef(MethodDefTable.RowIndex?)

    public static let tables: [TableID?] = [ .field, .methodDef ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .field(.init(oneBased: oneBasedIndex))
            case 1: self = .methodDef(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .field(rowIndex): return .init(rowIndex)
            case let .methodDef(rowIndex): return .init(rowIndex)
        }
    }
}

public enum MemberRefParent: CodedIndex {
    case typeDef(TypeDefTable.RowIndex?)
    case typeRef(TypeRefTable.RowIndex?)
    case moduleRef(ModuleRefTable.RowIndex?)
    case methodDef(MethodDefTable.RowIndex?)
    case typeSpec(TypeSpecTable.RowIndex?)

    public static let tables: [TableID?] = [ .typeDef, .typeRef, .moduleRef, .methodDef, .typeSpec ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .typeDef(.init(oneBased: oneBasedIndex))
            case 1: self = .typeRef(.init(oneBased: oneBasedIndex))
            case 2: self = .moduleRef(.init(oneBased: oneBasedIndex))
            case 3: self = .methodDef(.init(oneBased: oneBasedIndex))
            case 4: self = .typeSpec(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .typeDef(rowIndex): return .init(rowIndex)
            case let .typeRef(rowIndex): return .init(rowIndex)
            case let .moduleRef(rowIndex): return .init(rowIndex)
            case let .methodDef(rowIndex): return .init(rowIndex)
            case let .typeSpec(rowIndex): return .init(rowIndex)
        }
    }
}

public enum MethodDefOrRef: CodedIndex {
    case methodDef(MethodDefTable.RowIndex?)
    case memberRef(MemberRefTable.RowIndex?)

    public static let tables: [TableID?] = [ .methodDef, .memberRef ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .methodDef(.init(oneBased: oneBasedIndex))
            case 1: self = .memberRef(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .methodDef(rowIndex): return .init(rowIndex)
            case let .memberRef(rowIndex): return .init(rowIndex)
        }
    }
}

public enum ResolutionScope: CodedIndex {
    case module(ModuleTable.RowIndex?)
    case moduleRef(ModuleRefTable.RowIndex?)
    case assemblyRef(AssemblyRefTable.RowIndex?)
    case typeRef(TypeRefTable.RowIndex?)

    public static let tables: [TableID?] = [ .module, .moduleRef, .assemblyRef, .typeRef ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .module(.init(oneBased: oneBasedIndex))
            case 1: self = .moduleRef(.init(oneBased: oneBasedIndex))
            case 2: self = .assemblyRef(.init(oneBased: oneBasedIndex))
            case 3: self = .typeRef(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .module(rowIndex): return .init(rowIndex)
            case let .moduleRef(rowIndex): return .init(rowIndex)
            case let .assemblyRef(rowIndex): return .init(rowIndex)
            case let .typeRef(rowIndex): return .init(rowIndex)
        }
    }
}

public enum TypeDefOrRef: CodedIndex {
    case typeDef(TypeDefTable.RowIndex?)
    case typeRef(TypeRefTable.RowIndex?)
    case typeSpec(TypeSpecTable.RowIndex?)

    public static let tables: [TableID?] = [ .typeDef, .typeRef, .typeSpec ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .typeDef(.init(oneBased: oneBasedIndex))
            case 1: self = .typeRef(.init(oneBased: oneBasedIndex))
            case 2: self = .typeSpec(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .typeDef(rowIndex): return .init(rowIndex)
            case let .typeRef(rowIndex): return .init(rowIndex)
            case let .typeSpec(rowIndex): return .init(rowIndex)
        }
    }
}

public enum TypeOrMethodDef: CodedIndex {
    case typeDef(TypeDefTable.RowIndex?)
    case methodDef(MethodDefTable.RowIndex?)

    public static let tables: [TableID?] = [ .typeDef, .methodDef ]

    public init(tag: UInt8, oneBasedIndex: UInt32) {
        switch tag {
            case 0: self = .typeDef(.init(oneBased: oneBasedIndex))
            case 1: self = .methodDef(.init(oneBased: oneBasedIndex))
            default: fatalError()
        }
    }

    public var metadataToken: MetadataToken {
        switch self {
            case let .typeDef(rowIndex): return .init(rowIndex)
            case let .methodDef(rowIndex): return .init(rowIndex)
        }
    }
}
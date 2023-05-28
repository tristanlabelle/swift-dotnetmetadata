import WinMD

public class TypeDefinition {
    public unowned let assembly: Assembly
    private let tableRowIndex: TableRowIndex<WinMD.TypeDef>
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(assembly: Assembly, tableRowIndex: TableRowIndex<WinMD.TypeDef>) {
        self.assembly = assembly
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.TypeDef { database.tables.typeDef[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.typeName) }
    public var namespace: String { database.heaps.resolve(tableRow.typeNamespace) }
    public var visibility: Visibility {
        switch tableRow.flags.intersection(.visibilityMask) {
            case .public: return .public
            case .notPublic: return .assembly
            case .nestedFamily: return .family
            case .nestedFamORAssem: return .familyOrAssembly
            case .nestedFamANDAssem: return .familyAndAssembly
            case .nestedAssembly: return .assembly
            case .nestedPrivate: return .private
            default: fatalError()
        }
    }

    public var isAbstract: Bool { tableRow.flags.contains(TypeAttributes.abstract) }
    public var isSealed: Bool { tableRow.flags.contains(TypeAttributes.sealed) }

    public private(set) lazy var fullName: String = {
        let ns = namespace
        return ns.isEmpty ? name : "\(ns).\(name)"
    }()

    public private(set) lazy var base: TypeDefinition? = {
        assembly.resolve(tableRow.extends)
    }()

    public private(set) lazy var methods: [Method] = {
        getChildRowRange(parent: database.tables.typeDef,
            parentRowIndex: tableRowIndex,
            childTable: database.tables.methodDef,
            childSelector: { $0.methodList }).map {
            Method(definingType: self, tableRowIndex: $0)
        }
    }()

    public func findSingleMethod(name: String) -> Method? {
        methods.single { $0.name == name }
    }

    public private(set) lazy var fields: [Field] = {
        getChildRowRange(parent: database.tables.typeDef,
            parentRowIndex: tableRowIndex,
            childTable: database.tables.field,
            childSelector: { $0.fieldList }).map {
            Field(definingType: self, tableRowIndex: $0)
        }
    }()

    public func findSingleField(name: String) -> Field? {
        fields.single { $0.name == name }
    }
}
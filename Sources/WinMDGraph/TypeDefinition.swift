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

    private var lazyFullName: String?
    public var fullName: String {
        lazyInit(storage: &lazyFullName) {
            let ns = namespace
            return ns.isEmpty ? name : "\(ns).\(name)"
        }
    }

    private var lazyBase: TypeDefinition??
    public var base: TypeDefinition? {
        lazyInit(storage: &lazyBase) { assembly.resolve(tableRow.extends) }
    }

    private var lazyMethods: [Method]?
    public var methods: [Method] {
        lazyInit(storage: &lazyMethods) {
            getChildRowRange(parent: database.tables.typeDef,
                parentRowIndex: tableRowIndex,
                childTable: database.tables.methodDef,
                childSelector: { $0.methodList }).map {
                Method(definingType: self, tableRowIndex: TableRowIndex<MethodDef>(zeroBased: $0))
            }
        }
    }
}
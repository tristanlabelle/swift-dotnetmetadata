import WinMD

public class TypeDefinition {
    private unowned let assembly: Assembly
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
}
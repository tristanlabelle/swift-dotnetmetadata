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

    public lazy var name: String = database.heaps.resolve(tableRow.typeName)
    public lazy var namespace: String = database.heaps.resolve(tableRow.typeNamespace)
    public lazy var fullName: String = {
        let ns = namespace
        return ns.isEmpty ? name : "\(ns).\(name)"
    }()

    public lazy var base: TypeDefinition? = {
        assembly.resolve(tableRow.extends)
    }()
}
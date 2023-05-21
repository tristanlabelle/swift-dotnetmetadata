import WinMD

public final class Method {
    public unowned let definingType: TypeDefinition
    private let tableRowIndex: TableRowIndex<WinMD.MethodDef>
    internal var assembly: Assembly { definingType.assembly }
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(definingType: TypeDefinition, tableRowIndex: TableRowIndex<WinMD.MethodDef>) {
        self.definingType = definingType
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.MethodDef { database.tables.methodDef[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
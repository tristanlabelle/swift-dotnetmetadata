import WinMD

public final class Field {
    public unowned let definingType: TypeDefinition
    private let tableRowIndex: TableRowIndex<WinMD.Field>
    internal var assembly: Assembly { definingType.assembly }
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(definingType: TypeDefinition, tableRowIndex: TableRowIndex<WinMD.Field>) {
        self.definingType = definingType
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.Field { database.tables.field[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
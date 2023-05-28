import WinMD

public final class Property {
    public unowned let definingType: TypeDefinition
    private let tableRowIndex: TableRowIndex<WinMD.Property>
    internal var assembly: Assembly { definingType.assembly }
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(definingType: TypeDefinition, tableRowIndex: TableRowIndex<WinMD.Property>) {
        self.definingType = definingType
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.Property { database.tables.property[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
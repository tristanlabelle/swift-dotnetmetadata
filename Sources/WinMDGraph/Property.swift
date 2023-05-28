import WinMD

public final class Property {
    public unowned let definingType: TypeDefinition
    private let tableRowIndex: Table<WinMD.Property>.RowIndex
    internal var assembly: Assembly { definingType.assembly }
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(definingType: TypeDefinition, tableRowIndex: Table<WinMD.Property>.RowIndex) {
        self.definingType = definingType
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.Property { database.tables.property[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
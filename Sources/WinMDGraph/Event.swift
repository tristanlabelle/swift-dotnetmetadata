import WinMD

public final class Event {
    public unowned let definingType: TypeDefinition
    private let tableRowIndex: Table<WinMD.Event>.RowIndex
    internal var assembly: Assembly { definingType.assembly }
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(definingType: TypeDefinition, tableRowIndex: Table<WinMD.Event>.RowIndex) {
        self.definingType = definingType
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.Event { database.tables.event[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
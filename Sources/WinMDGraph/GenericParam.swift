import WinMD

public final class GenericParam {
    public unowned let definingType: TypeDefinition
    private let tableRowIndex: Table<WinMD.GenericParam>.RowIndex
    internal var assembly: Assembly { definingType.assembly }
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(definingType: TypeDefinition, tableRowIndex: Table<WinMD.GenericParam>.RowIndex) {
        self.definingType = definingType
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.GenericParam { database.tables.genericParam[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
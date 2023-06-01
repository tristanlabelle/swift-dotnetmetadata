import WinMD

public final class Event {
    internal unowned let definingTypeFromMetadata: TypeDefinitionFromMetadata
    private let tableRowIndex: Table<WinMD.Event>.RowIndex
    internal var assembly: AssemblyFromMetadata { definingTypeFromMetadata.assemblyFromMetadata }
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(definingType: TypeDefinitionFromMetadata, tableRowIndex: Table<WinMD.Event>.RowIndex) {
        self.definingTypeFromMetadata = definingType
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.Event { database.tables.event[tableRowIndex] }

    public var definingType: TypeDefinition { definingTypeFromMetadata }
    public var name: String { database.heaps.resolve(tableRow.name) }
}
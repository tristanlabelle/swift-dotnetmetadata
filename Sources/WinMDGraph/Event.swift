import WinMD

public final class Event {
    internal unowned let definingTypeImpl: TypeDefinitionFromMetadataImpl
    private let tableRowIndex: Table<WinMD.Event>.RowIndex

    init(definingTypeImpl: TypeDefinitionFromMetadataImpl, tableRowIndex: Table<WinMD.Event>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.parent }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: WinMD.Event { database.tables.event[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
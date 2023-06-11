import DotNetMDPhysical

public final class Event {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    private let tableRowIndex: Table<DotNetMDPhysical.Event>.RowIndex

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDPhysical.Event>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: DotNetMDPhysical.Event { database.tables.event[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
import WinMD

public final class Property {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    private let tableRowIndex: Table<WinMD.Property>.RowIndex

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<WinMD.Property>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: WinMD.Property { database.tables.property[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
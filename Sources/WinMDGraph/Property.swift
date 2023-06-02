import WinMD

public final class Property {
    internal unowned let definingTypeImpl: TypeDefinitionFromMetadataImpl
    private let tableRowIndex: Table<WinMD.Property>.RowIndex

    init(definingTypeImpl: TypeDefinitionFromMetadataImpl, tableRowIndex: Table<WinMD.Property>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.parent }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: WinMD.Property { database.tables.property[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
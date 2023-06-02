import WinMD

public final class GenericParam {
    internal unowned let definingTypeImpl: TypeDefinitionFromMetadataImpl
    private let tableRowIndex: Table<WinMD.GenericParam>.RowIndex

    init(definingTypeImpl: TypeDefinitionFromMetadataImpl, tableRowIndex: Table<WinMD.GenericParam>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.parent }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: WinMD.GenericParam { database.tables.genericParam[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
}
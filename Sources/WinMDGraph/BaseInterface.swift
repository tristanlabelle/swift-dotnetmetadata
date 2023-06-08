import WinMD

public final class BaseInterface {
    internal unowned let inheritingTypeImpl: TypeDefinition.MetadataImpl
    private let tableRowIndex: Table<WinMD.InterfaceImpl>.RowIndex

    init(inheritingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<WinMD.InterfaceImpl>.RowIndex) {
        self.inheritingTypeImpl = inheritingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var inheritingType: TypeDefinition { inheritingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { inheritingTypeImpl.assemblyImpl }
    internal var database: Database { inheritingTypeImpl.database }
    private var tableRow: WinMD.InterfaceImpl { database.tables.interfaceImpl[tableRowIndex] }
    public var interface: Type { assemblyImpl.resolve(tableRow.interface)! }
}
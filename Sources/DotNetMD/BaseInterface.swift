import DotNetMDFormat

public final class BaseInterface {
    internal unowned let inheritingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: InterfaceImplTable.RowIndex

    init(inheritingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: InterfaceImplTable.RowIndex) {
        self.inheritingTypeImpl = inheritingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var inheritingType: TypeDefinition { inheritingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { inheritingTypeImpl.assemblyImpl }
    internal var database: Database { inheritingTypeImpl.database }
    private var tableRow: InterfaceImplTable.Row { database.tables.interfaceImpl[tableRowIndex] }
    public var interface: BoundType { assemblyImpl.resolveOptionalBoundType(tableRow.interface, typeContext: inheritingType)! }
}
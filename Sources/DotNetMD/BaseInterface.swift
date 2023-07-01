import DotNetMDFormat

public final class BaseInterface {
    internal unowned let inheritingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: Table<DotNetMDFormat.InterfaceImpl>.RowIndex

    init(inheritingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.InterfaceImpl>.RowIndex) {
        self.inheritingTypeImpl = inheritingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var inheritingType: TypeDefinition { inheritingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { inheritingTypeImpl.assemblyImpl }
    internal var database: Database { inheritingTypeImpl.database }
    private var tableRow: DotNetMDFormat.InterfaceImpl { database.tables.interfaceImpl[tableRowIndex] }
    public var interface: BoundType { assemblyImpl.resolve(tableRow.interface, typeContext: inheritingType)! }

    public var unboundInterface: TypeDefinition! {
        guard case .definition(let interface) = interface else { fatalError() }
        return interface.definition
    }
}
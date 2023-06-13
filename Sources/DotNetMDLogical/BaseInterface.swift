import DotNetMDPhysical

public final class BaseInterface {
    internal unowned let inheritingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: Table<DotNetMDPhysical.InterfaceImpl>.RowIndex

    init(inheritingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDPhysical.InterfaceImpl>.RowIndex) {
        self.inheritingTypeImpl = inheritingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var inheritingType: TypeDefinition { inheritingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { inheritingTypeImpl.assemblyImpl }
    internal var database: Database { inheritingTypeImpl.database }
    private var tableRow: DotNetMDPhysical.InterfaceImpl { database.tables.interfaceImpl[tableRowIndex] }
    public var interface: BoundType { assemblyImpl.resolve(tableRow.interface)! }

    public var unboundInterface: TypeDefinition! {
        guard case .definition(let interface) = interface else { fatalError() }
        return interface.definition
    }
}
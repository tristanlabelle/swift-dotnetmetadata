import DotNetMetadataFormat

public final class BaseInterface {
    internal unowned let inheritingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: InterfaceImplTable.RowIndex

    init(inheritingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: InterfaceImplTable.RowIndex) {
        self.inheritingTypeImpl = inheritingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var inheritingType: TypeDefinition { inheritingTypeImpl.owner }
    internal var assembly: Assembly { inheritingTypeImpl.assembly }
    internal var moduleFile: ModuleFile { inheritingTypeImpl.moduleFile }
    private var tableRow: InterfaceImplTable.Row { moduleFile.interfaceImplTable[tableRowIndex] }
    public var interface: BoundType { assembly.resolveOptionalBoundType(tableRow.interface, typeContext: inheritingType)! }

    public private(set) lazy var attributes: [Attribute] = {
        assembly.getAttributes(owner: .interfaceImpl(tableRowIndex))
    }()
}
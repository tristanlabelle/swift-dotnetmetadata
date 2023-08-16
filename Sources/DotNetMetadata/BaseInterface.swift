import DotNetMetadataFormat

public final class BaseInterface {
    public unowned let inheritingType: TypeDefinition
    internal let tableRowIndex: InterfaceImplTable.RowIndex

    init(inheritingType: TypeDefinition, tableRowIndex: InterfaceImplTable.RowIndex) {
        self.inheritingType = inheritingType
        self.tableRowIndex = tableRowIndex
    }

    internal var assembly: Assembly { inheritingType.assembly }
    internal var moduleFile: ModuleFile { inheritingType.moduleFile }
    private var tableRow: InterfaceImplTable.Row { moduleFile.interfaceImplTable[tableRowIndex] }
    public var interface: BoundType { assembly.resolveOptionalBoundType(tableRow.interface, typeContext: inheritingType)! }

    public private(set) lazy var attributes: [Attribute] = {
        assembly.getAttributes(owner: .interfaceImpl(tableRowIndex))
    }()
}
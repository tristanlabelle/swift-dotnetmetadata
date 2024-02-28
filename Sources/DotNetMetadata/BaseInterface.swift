import DotNetMetadataFormat

public final class BaseInterface: Attributable {
    public unowned let inheritingType: TypeDefinition
    internal let tableRowIndex: TableRowIndex // In InterfaceImpl table

    init(inheritingType: TypeDefinition, tableRowIndex: TableRowIndex) {
        self.inheritingType = inheritingType
        self.tableRowIndex = tableRowIndex
    }

    public var assembly: Assembly { inheritingType.assembly }
    internal var moduleFile: ModuleFile { inheritingType.moduleFile }
    private var tableRow: InterfaceImplTable.Row { moduleFile.interfaceImplTable[tableRowIndex] }

    private lazy var _interface = Result {
        guard let boundType = try assembly.resolveTypeDefOrRefToBoundType(tableRow.interface, typeContext: inheritingType),
            let interfaceDefinition = boundType.definition as? InterfaceDefinition else { throw InvalidFormatError.tableConstraint }
        return interfaceDefinition.bind(genericArgs: boundType.genericArgs)
    }
    public var interface: BoundInterface { get throws { try _interface.get() } }

    public var attributeTarget: AttributeTargets { .interfaceImpl }
    public private(set) lazy var attributes: [Attribute] = {
        assembly.getAttributes(owner: .init(tag: .interfaceImpl, rowIndex: tableRowIndex))
    }()
}
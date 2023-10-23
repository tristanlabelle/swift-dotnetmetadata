import DotNetMetadataFormat

public final class BaseInterface: Attributable {
    public unowned let inheritingType: TypeDefinition
    internal let tableRowIndex: InterfaceImplTable.RowIndex

    init(inheritingType: TypeDefinition, tableRowIndex: InterfaceImplTable.RowIndex) {
        self.inheritingType = inheritingType
        self.tableRowIndex = tableRowIndex
    }

    internal var assembly: Assembly { inheritingType.assembly }
    internal var moduleFile: ModuleFile { inheritingType.moduleFile }
    private var tableRow: InterfaceImplTable.Row { moduleFile.interfaceImplTable[tableRowIndex] }

    private lazy var _interface = Result {
        guard let boundType = try assembly.resolveOptionalBoundType(tableRow.interface, typeContext: inheritingType),
            let interfaceDefinition = boundType.definition as? InterfaceDefinition else { throw InvalidFormatError.tableConstraint }
        return interfaceDefinition.bind(genericArgs: boundType.genericArgs)
    }
    public var interface: BoundInterface { get throws { try _interface.get() } }

    public var attributeTarget: AttributeTargets { .none } // No AttributeTargets value for this
    public private(set) lazy var attributes: [Attribute] = { assembly.getAttributes(owner: tableRowIndex.metadataToken) }()
}
import DotNetMetadataFormat

public final class BaseInterface: Attributable {
    public private(set) weak var inheritingType: TypeDefinition!
    internal let tableRowIndex: TableRowIndex // In InterfaceImpl table

    init(inheritingType: TypeDefinition, tableRowIndex: TableRowIndex) {
        self.inheritingType = inheritingType
        self.tableRowIndex = tableRowIndex
    }

    public var assembly: Assembly { inheritingType.assembly }
    internal var moduleFile: ModuleFile { inheritingType.moduleFile }
    private var tableRow: InterfaceImplTable.Row { moduleFile.interfaceImplTable[tableRowIndex] }

    private var cachedInterface: BoundInterface?
    public var interface: BoundInterface { get throws {
        try cachedInterface.lazyInit {
            guard let boundType = try assembly.resolveTypeDefOrRefToBoundType(tableRow.interface, typeContext: inheritingType),
                let interfaceDefinition = boundType.definition as? InterfaceDefinition else { throw InvalidFormatError.tableConstraint }
            return interfaceDefinition.bind(genericArgs: boundType.genericArgs)
        }
    } }

    public var attributeTarget: AttributeTargets { .interfaceImpl }
    private var cachedAttributes: [Attribute]?
    public var attributes: [Attribute] {
        cachedAttributes.lazyInit {
            assembly.getAttributes(owner: .init(tag: .interfaceImpl, rowIndex: tableRowIndex))
        }
    }

    internal func breakReferenceCycles() {
        if let attributes = cachedAttributes {
            for attribute in attributes {
                attribute.breakReferenceCycles()
            }
        }

        cachedInterface = nil
    }
}
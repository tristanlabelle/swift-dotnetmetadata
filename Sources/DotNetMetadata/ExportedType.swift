import DotNetMetadataFormat

/// A type that is exported but whose definition is in another assembly.
public final class ExportedType {
    public unowned let assembly: Assembly
    internal let tableRowIndex: ExportedTypeTable.RowIndex
    private var tableRow: ExportedTypeTable.Row { moduleFile.exportedTypeTable[tableRowIndex] }

    internal init(assembly: Assembly, tableRowIndex: ExportedTypeTable.RowIndex) {
        self.assembly = assembly
        self.tableRowIndex = tableRowIndex
    }

    internal var moduleFile: ModuleFile { assembly.moduleFile }
    public var context: AssemblyLoadContext { assembly.context }

    public var name: String { moduleFile.resolve(tableRow.typeName) }

    public var namespace: String? {
        let tableRow = tableRow
        // Normally, no namespace is represented by a zero string heap index
        guard tableRow.typeNamespace.value != 0 else { return nil }
        let value = moduleFile.resolve(tableRow.typeNamespace)
        return value.isEmpty ? nil : value
    }

    public private(set) lazy var fullName: String = {
        // TODO: Support nested exported types
        makeFullTypeName(namespace: namespace, name: name)
    }()

    private lazy var _definition = Result {
        switch tableRow.implementation {
            case let .assemblyRef(index):
                guard let index else { throw DotNetMetadataFormat.InvalidFormatError.tableConstraint }
                let definitionAssembly = try self.assembly.resolve(index)
                // TODO: Optimize using the typeDefId field
                // TODO: Support recursive exported types
                guard let typeDefinition = try definitionAssembly.resolveTypeDefinition(namespace: namespace, name: name) else {
                    throw DotNetMetadataFormat.InvalidFormatError.tableConstraint
                }
                return typeDefinition
            default:
                fatalError("Not implemented: \(#function)")
        }
    }

    public var definition: TypeDefinition { get throws { try _definition.get() } }
}
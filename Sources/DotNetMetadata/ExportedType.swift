import DotNetMetadataFormat

/// A type that is exported but whose definition is in another assembly.
public final class ExportedType {
    public private(set) weak var assembly: Assembly!
    internal let tableRowIndex: TableRowIndex // In ExportedType table
    private var tableRow: ExportedTypeTable.Row { moduleFile.exportedTypeTable[tableRowIndex] }

    internal init(assembly: Assembly, tableRowIndex: TableRowIndex) {
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

    private var cachedDefinition: TypeDefinition?
    public var definition: TypeDefinition { get throws {
        try cachedDefinition.lazyInit {
            let implementationCodedIndex = tableRow.implementation
            guard let implementationRowIndex = implementationCodedIndex.rowIndex else {
                throw DotNetMetadataFormat.InvalidFormatError.tableConstraint
            }
            switch try implementationCodedIndex.tag {
                case .assemblyRef:
                    let assemblyReference = try self.assembly.resolveAssemblyRef(rowIndex: implementationRowIndex)
                    // TODO: Optimize using the typeDefId field
                    // TODO: Support recursive exported types
                    let typeReference = AssemblyLoadContext.TypeReference(
                        assembly: assemblyReference.identity,
                        assemblyFlags: assemblyReference.flags,
                        namespace: namespace,
                        name: name)
                    return try context.resolve(typeReference)
                default:
                    fatalError("Not implemented: \(#function)")
            }
        }
    } }

    public func breakReferenceCycles() {
        cachedDefinition = nil
    }
}
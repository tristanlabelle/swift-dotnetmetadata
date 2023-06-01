import WinMD

public final class Field {
    internal unowned let definingTypeFromMetadata: TypeDefinitionFromMetadata
    private let tableRowIndex: Table<WinMD.Field>.RowIndex
    internal var assembly: AssemblyFromMetadata { definingTypeFromMetadata.assemblyFromMetadata }
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(definingType: TypeDefinitionFromMetadata, tableRowIndex: Table<WinMD.Field>.RowIndex) {
        self.definingTypeFromMetadata = definingType
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.Field { database.tables.field[tableRowIndex] }

    public var definingType: TypeDefinition { definingTypeFromMetadata }
    public var name: String { database.heaps.resolve(tableRow.name) }
    public var isStatic: Bool { tableRow.flags.contains(.`static`) }
    public var isInitOnly: Bool { tableRow.flags.contains(.initOnly) }
    public var isLiteral: Bool { tableRow.flags.contains(.literal) }

    public var visibility: Visibility {
        switch tableRow.flags.intersection(.fieldAccessMask) {
            case .compilerControlled: return .compilerControlled
            case .private: return .private
            case .assembly: return .assembly
            case .famANDAssem: return .familyAndAssembly
            case .famORAssem: return .familyOrAssembly
            case .family: return .family
            case .public: return .public
            default: fatalError()
        }
    }
}
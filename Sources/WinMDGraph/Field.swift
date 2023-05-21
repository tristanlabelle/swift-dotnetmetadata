import WinMD

public final class Field {
    public unowned let definingType: TypeDefinition
    private let tableRowIndex: TableRowIndex<WinMD.Field>
    internal var assembly: Assembly { definingType.assembly }
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(definingType: TypeDefinition, tableRowIndex: TableRowIndex<WinMD.Field>) {
        self.definingType = definingType
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.Field { database.tables.field[tableRowIndex] }

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
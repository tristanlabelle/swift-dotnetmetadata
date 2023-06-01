import WinMD

public final class Method {
    internal unowned let definingTypeFromMetadata: TypeDefinitionFromMetadata
    private let tableRowIndex: Table<WinMD.MethodDef>.RowIndex
    internal var assembly: AssemblyFromMetadata { definingTypeFromMetadata.assemblyFromMetadata }
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(definingType: TypeDefinitionFromMetadata, tableRowIndex: Table<WinMD.MethodDef>.RowIndex) {
        self.definingTypeFromMetadata = definingType
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.MethodDef { database.tables.methodDef[tableRowIndex] }

    public var definingType: TypeDefinition { definingTypeFromMetadata }
    public var name: String { database.heaps.resolve(tableRow.name) }
    public var isStatic: Bool { tableRow.flags.contains(.`static`) }
    public var isVirtual: Bool { tableRow.flags.contains(.virtual) }
    public var isAbstract: Bool { tableRow.flags.contains(.abstract) }
    public var isFinal: Bool { tableRow.flags.contains(.final) }
    public var isSpecialName: Bool { tableRow.flags.contains(.specialName) }

    public var visibility: Visibility {
        switch tableRow.flags.intersection(.memberAccessMask) {
            case .compilerControlled: return .compilerControlled
            case .private: return .private
            case .assem: return .assembly
            case .famANDAssem: return .familyAndAssembly
            case .famORAssem: return .familyOrAssembly
            case .family: return .family
            case .public: return .public
            default: fatalError()
        }
    }
}
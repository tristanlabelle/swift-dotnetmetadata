import DotNetMDPhysical

public final class Field {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: Table<DotNetMDPhysical.Field>.RowIndex

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDPhysical.Field>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { definingTypeImpl.assemblyImpl }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: DotNetMDPhysical.Field { database.tables.field[tableRowIndex] }

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

    private lazy var signature: FieldSig = {
        let signatureBlob = database.heaps.resolve(tableRow.signature)
        return try! FieldSig(blob: signatureBlob)
    }()

    public private(set) lazy var type: BoundType = assemblyImpl.resolve(signature.type, typeContext: definingType)
}
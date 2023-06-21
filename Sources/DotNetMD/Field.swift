import DotNetMDFormat

public final class Field {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: Table<DotNetMDFormat.Field>.RowIndex

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.Field>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { definingTypeImpl.assemblyImpl }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: DotNetMDFormat.Field { database.tables.field[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
    public var isStatic: Bool { tableRow.flags.contains(.`static`) }
    public var isInitOnly: Bool { tableRow.flags.contains(.initOnly) }

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

    private lazy var signature = Result {
        let signatureBlob = database.heaps.resolve(tableRow.signature)
        return try! FieldSig(blob: signatureBlob)
    }

    private lazy var _type = Result { try assemblyImpl.resolve(signature.get().type, typeContext: definingType) }
    public var type: BoundType { get throws { try _type.get() } }

    private lazy var _literalValue = Result { () -> Constant? in
        guard tableRow.flags.contains(.literal) else { return nil }
        guard let constantRowIndex = database.tables.constant.findAny(primaryKey: MetadataToken(tableRowIndex)) else {
            return nil
        }
    
        let constantRow = database.tables.constant[constantRowIndex]
        guard constantRow.type != .nullRef else { return .null }

        let blob = database.heaps.resolve(constantRow.value)
        return try! Constant(buffer: blob, type: constantRow.type)
    }
    public var literalValue: Constant? { get throws { try _literalValue.get() } }
}
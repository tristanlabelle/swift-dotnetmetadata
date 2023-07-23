import DotNetMDFormat

public final class Field {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: FieldTable.RowIndex

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: FieldTable.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { definingTypeImpl.assemblyImpl }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: FieldTable.Row { database.tables.field[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
    public var isStatic: Bool { tableRow.flags.contains(.`static`) }
    public var isInitOnly: Bool { tableRow.flags.contains(.initOnly) }
    public var visibility: Visibility { tableRow.flags.visibility }

    public private(set) lazy var explicitOffset: Int? = { () -> Int? in
        guard let fieldLayoutRowIndex = database.tables.fieldLayout.findAny(primaryKey: tableRowIndex.metadataToken.tableKey)
        else { return nil }

        let fieldLayoutRow = database.tables.fieldLayout[fieldLayoutRowIndex]
        return Int(fieldLayoutRow.offset)
    }()

    private lazy var _signature = Result {
        let signatureBlob = database.heaps.resolve(tableRow.signature)
        return try! FieldSig(blob: signatureBlob)
    }
    public var signature: FieldSig { get throws { try _signature.get() } }

    private lazy var _type = Result { try assemblyImpl.resolve(signature.type, typeContext: definingType) }
    public var type: TypeNode { get throws { try _type.get() } }

    private lazy var _literalValue = Result {
        guard tableRow.flags.contains(.literal) else { return nil as Constant? }
        return try Constant(database: database, owner: .field(tableRowIndex))
    }
    public var literalValue: Constant? { get throws { try _literalValue.get() } }

    public private(set) lazy var attributes: [Attribute] = {
        assemblyImpl.getAttributes(owner: .field(tableRowIndex))
    }()
}

extension Field: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Field, rhs: Field) -> Bool { lhs === rhs }
}
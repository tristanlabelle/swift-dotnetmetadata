import DotNetMetadataFormat

public final class Field: Member {
    internal let tableRowIndex: FieldTable.RowIndex
    private var tableRow: FieldTable.Row { moduleFile.fieldTable[tableRowIndex] }
    private var flags: FieldAttributes { tableRow.flags }

    init(definingType: TypeDefinition, tableRowIndex: FieldTable.RowIndex) {
        self.tableRowIndex = tableRowIndex
        super.init(definingType: definingType)
    }

    internal override func resolveName() -> String { moduleFile.resolve(tableRow.name) }
    public override var nameKind: NameKind { flags.nameKind }
    public override var isStatic: Bool { flags.contains(.`static`) }
    public var visibility: Visibility { flags.visibility }
    public var isPublic: Bool { visibility == .public }
    public var isInitOnly: Bool { flags.contains(.initOnly) }

    public private(set) lazy var explicitOffset: Int? = { () -> Int? in
        guard let fieldLayoutRowIndex = moduleFile.fieldLayoutTable.findAny(primaryKey: tableRowIndex.metadataToken.tableKey)
        else { return nil }

        let fieldLayoutRow = moduleFile.fieldLayoutTable[fieldLayoutRowIndex]
        return Int(fieldLayoutRow.offset)
    }()

    private lazy var _signature = Result {
        let signatureBlob = moduleFile.resolve(tableRow.signature)
        return try! FieldSig(blob: signatureBlob)
    }
    public var signature: FieldSig { get throws { try _signature.get() } }

    private lazy var _type = Result { try assembly.resolve(signature.type, typeContext: definingType) }
    public var type: TypeNode { get throws { try _type.get() } }

    private lazy var _literalValue = Result {
        guard tableRow.flags.contains(.literal) else { return nil as Constant? }
        return try Constant(moduleFile: moduleFile, owner: .field(tableRowIndex))
    }
    public var literalValue: Constant? { get throws { try _literalValue.get() } }

    public private(set) lazy var attributes: [Attribute] = {
        assembly.getAttributes(owner: .field(tableRowIndex))
    }()
}
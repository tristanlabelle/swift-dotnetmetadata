import DotNetMetadataFormat

public final class Field: Member {
    internal let tableRowIndex: TableRowIndex // In Field table
    private var tableRow: FieldTable.Row { moduleFile.fieldTable[tableRowIndex] }
    private var flags: FieldAttributes { tableRow.flags }

    init(definingType: TypeDefinition, tableRowIndex: TableRowIndex) {
        self.tableRowIndex = tableRowIndex
        super.init(definingType: definingType)
    }

    public override var metadataToken: MetadataToken { .init(tableID: .field, rowIndex: tableRowIndex) }
    internal override func resolveName() -> String { moduleFile.resolve(tableRow.name) }
    public override var nameKind: NameKind { flags.nameKind }
    public override var isStatic: Bool { flags.contains(.`static`) }
    public override var attributeTarget: AttributeTargets { .field }
    internal override var attributesKeyTag: CodedIndices.HasCustomAttribute.Tag { .field }
    public var visibility: Visibility { flags.visibility }
    public var isPublic: Bool { visibility == .public }
    public var isInitOnly: Bool { flags.contains(.initOnly) }
    public var isLiteral: Bool { flags.contains(.literal) }

    public private(set) lazy var explicitOffset: Int? = { () -> Int? in
        guard let fieldLayoutRowIndex = moduleFile.fieldLayoutTable.findAny(
            primaryKey: .init(index: tableRowIndex))
        else { return nil }

        let fieldLayoutRow = moduleFile.fieldLayoutTable[fieldLayoutRowIndex]
        return Int(fieldLayoutRow.offset)
    }()

    private var cachedSignature: FieldSig?
    public var signature: FieldSig { get throws {
        try cachedSignature.lazyInit {
            let signatureBlob = moduleFile.resolve(tableRow.signature)
            return try FieldSig(blob: signatureBlob)
        }
    } }

    private var cachedType: TypeNode?
    public var type: TypeNode { get throws {
        try cachedType.lazyInit {
            try assembly.resolveTypeSig(signature.type, typeContext: definingType)
        }
    } }

    private lazy var _literalValue = Result {
        guard tableRow.flags.contains(.literal) else { return nil as Constant? }
        return try Constant(moduleFile: moduleFile, owner: .init(tag: .field, rowIndex: tableRowIndex))
    }
    public var literalValue: Constant? { get throws { try _literalValue.get() } }
}
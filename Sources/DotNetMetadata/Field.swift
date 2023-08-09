import DotNetMetadataFormat

public final class Field: Member {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: FieldTable.RowIndex

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: FieldTable.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public override var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: MetadataAssemblyImpl { definingTypeImpl.assemblyImpl }
    internal var moduleFile: ModuleFile { definingTypeImpl.moduleFile }
    private var tableRow: FieldTable.Row { moduleFile.fieldTable[tableRowIndex] }

    public override var name: String { moduleFile.resolve(tableRow.name) }
    public override var isStatic: Bool { tableRow.flags.contains(.`static`) }
    public var isInitOnly: Bool { tableRow.flags.contains(.initOnly) }
    public override var visibility: Visibility { tableRow.flags.visibility }

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

    private lazy var _type = Result { try assemblyImpl.resolve(signature.type, typeContext: definingType) }
    public var type: TypeNode { get throws { try _type.get() } }

    private lazy var _literalValue = Result {
        guard tableRow.flags.contains(.literal) else { return nil as Constant? }
        return try Constant(moduleFile: moduleFile, owner: .field(tableRowIndex))
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
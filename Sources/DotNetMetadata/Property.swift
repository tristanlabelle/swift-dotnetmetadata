import DotNetMetadataFormat

public class Property: Member {
    public static let getterPrefix = "get_"
    public static let setterPrefix = "set_"

    internal let tableRowIndex: TableRowIndex // In Property table
    private var tableRow: PropertyTable.Row { moduleFile.propertyTable[tableRowIndex] }
    private var flags: PropertyAttributes { tableRow.flags }
    internal let propertySig: PropertySig

    fileprivate init(definingType: TypeDefinition, tableRowIndex: TableRowIndex, propertySig: PropertySig) {
        self.tableRowIndex = tableRowIndex
        self.propertySig = propertySig
        super.init(definingType: definingType)
    }

    internal static func create(definingType: TypeDefinition, tableRowIndex: TableRowIndex) -> Property {
        let row = definingType.moduleFile.propertyTable[tableRowIndex]
        let propertySig = try! PropertySig(blob: definingType.moduleFile.resolve(row.type))
        if propertySig.params.count == 0 {
            return Property(definingType: definingType, tableRowIndex: tableRowIndex, propertySig: propertySig)
        }
        else {
            return Indexer(definingType: definingType, tableRowIndex: tableRowIndex, propertySig: propertySig)
        }
    }

    public override var metadataToken: MetadataToken { .init(tableID: .property, rowIndex: tableRowIndex) }
    internal override func resolveName() -> String { moduleFile.resolve(tableRow.name) }
    public override var nameKind: NameKind { flags.nameKind }
    // Assume all accessors are consistently static or instance
    public override var isStatic: Bool { anyAccessor?.isStatic ?? false }
    public override var attributeTarget: AttributeTargets { .property }
    internal override var attributesKeyTag: CodedIndices.HasCustomAttribute.Tag { .property }

    private lazy var _type = Result { try assembly.resolveTypeSig(propertySig.type, typeContext: definingType) }
    public var type: TypeNode { get throws { try _type.get() } }

    private struct Accessors {
        var getter: Method?
        var setter: Method?
        var others: [Method] = []
    }

    private lazy var accessors = Result { [self] in
        var accessors = Accessors()
        for entry in definingType.getAccessors(owner: .init(tag: .property, rowIndex: tableRowIndex)) {
            if entry.attributes == .getter { accessors.getter = entry.method }
            else if entry.attributes == .setter { accessors.setter = entry.method }
            else if entry.attributes == .other { accessors.others.append(entry.method) }
            else { fatalError("Unexpected property accessor attributes value") }
        }
        return accessors
    }

    public var getter: Method? { get throws { try accessors.get().getter } }
    public var setter: Method? { get throws { try accessors.get().setter } }
    public var otherAccessors: [Method] { get throws { try accessors.get().others } }

    private var anyAccessor: Method? {
        guard let accessors = try? self.accessors.get() else { return nil }
        return accessors.getter ?? accessors.setter ?? accessors.others.first
    }

    public var hasPublicGetter: Bool { (try? getter)?.isPublic == true }
    public var hasPublicSetter: Bool { (try? setter)?.isPublic == true }
    public var hasPublicGetterAndSetter: Bool { hasPublicGetter && hasPublicSetter }
    public var isVirtual: Bool { anyAccessor?.isAbstract ?? false }
    public var isAbstract: Bool { anyAccessor?.isVirtual ?? false }
    public var isFinal: Bool { anyAccessor?.isFinal ?? false }
}

public final class Indexer: Property {
    internal override init(definingType: TypeDefinition, tableRowIndex: TableRowIndex, propertySig: PropertySig) {
        super.init(definingType: definingType, tableRowIndex: tableRowIndex, propertySig: propertySig)
    }
}

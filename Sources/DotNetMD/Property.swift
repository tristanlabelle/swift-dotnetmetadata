import DotNetMDFormat

public class Property {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: Table<DotNetMDFormat.Property>.RowIndex
    internal let propertySig: PropertySig

    fileprivate init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.Property>.RowIndex, propertySig: PropertySig) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
        self.propertySig = propertySig
    }

    internal static func create(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.Property>.RowIndex) -> Property {
        let row = definingTypeImpl.database.tables.property[tableRowIndex]
        let propertySig = try! PropertySig(blob: definingTypeImpl.database.heaps.resolve(row.type))
        if propertySig.params.count == 0 {
            return Property(definingTypeImpl: definingTypeImpl, tableRowIndex: tableRowIndex, propertySig: propertySig)
        }
        else {
            return Indexer(definingTypeImpl: definingTypeImpl, tableRowIndex: tableRowIndex, propertySig: propertySig)
        }
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { definingTypeImpl.assemblyImpl }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: DotNetMDFormat.Property { database.tables.property[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }

    public private(set) lazy var type: BoundType = assemblyImpl.resolve(propertySig.type, typeContext: definingType)

    private struct Accessors {
        var getter: Method?
        var setter: Method?
        var others: [Method] = []
    }

    private lazy var accessors: Accessors = { [self] in
        var accessors = Accessors()
        for entry in definingTypeImpl.getAccessors(token: MetadataToken(tableRowIndex)) {
            if entry.attributes == .getter { accessors.getter = entry.method }
            else if entry.attributes == .setter { accessors.setter = entry.method }
            else if entry.attributes == .other { accessors.others.append(entry.method) }
            else { fatalError("Unexpected property accessor attributes value") }
        }
        return accessors
    }()

    public var getter: Method? { accessors.getter }
    public var setter: Method? { accessors.setter }
    public var otherAccessors: [Method] { accessors.others }

    public var visibility: Visibility {
        (getter ?? setter ?? otherAccessors.first)?.visibility ?? .public
    }
}

public final class Indexer: Property {
    internal override init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.Property>.RowIndex, propertySig: PropertySig) {
        super.init(definingTypeImpl: definingTypeImpl, tableRowIndex: tableRowIndex, propertySig: propertySig)
    }
}
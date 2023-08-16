import DotNetMetadataFormat

public class Property: Member {
    public static let getterPrefix = "get_"
    public static let setterPrefix = "set_"

    private unowned let _definingType: TypeDefinition
    internal let tableRowIndex: PropertyTable.RowIndex
    internal let propertySig: PropertySig

    fileprivate init(definingType: TypeDefinition, tableRowIndex: PropertyTable.RowIndex, propertySig: PropertySig) {
        self._definingType = definingType
        self.tableRowIndex = tableRowIndex
        self.propertySig = propertySig
    }

    internal static func create(definingType: TypeDefinition, tableRowIndex: PropertyTable.RowIndex) -> Property {
        let row = definingType.moduleFile.propertyTable[tableRowIndex]
        let propertySig = try! PropertySig(blob: definingType.moduleFile.resolve(row.type))
        if propertySig.params.count == 0 {
            return Property(definingType: definingType, tableRowIndex: tableRowIndex, propertySig: propertySig)
        }
        else {
            return Indexer(definingType: definingType, tableRowIndex: tableRowIndex, propertySig: propertySig)
        }
    }

    public override var definingType: TypeDefinition { _definingType }
    internal var moduleFile: ModuleFile { definingType.moduleFile }
    private var tableRow: PropertyTable.Row { moduleFile.propertyTable[tableRowIndex] }

    public override var name: String { moduleFile.resolve(tableRow.name) }

    private lazy var _type = Result { assembly.resolve(propertySig.type, typeContext: definingType) }
    public var type: TypeNode { get throws { try _type.get() } }

    private struct Accessors {
        var getter: Method?
        var setter: Method?
        var others: [Method] = []
    }

    private lazy var accessors = Result { [self] in
        var accessors = Accessors()
        for entry in definingType.getAccessors(owner: .property(tableRowIndex)) {
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

    // CLS adds some uniformity guarantees:
    // §II.22.28 "All methods for a given Property or Event shall have the same accessibility"
    public override var visibility: Visibility { anyAccessor?.visibility ?? .public }
    public override var isStatic: Bool { anyAccessor?.isStatic ?? false }
    public var isVirtual: Bool { anyAccessor?.isAbstract ?? false }
    public var isAbstract: Bool { anyAccessor?.isVirtual ?? false }
    public var isFinal: Bool { anyAccessor?.isFinal ?? false }

    public private(set) lazy var attributes: [Attribute] = {
        assembly.getAttributes(owner: .property(tableRowIndex))
    }()
}

public final class Indexer: Property {
    internal override init(definingType: TypeDefinition, tableRowIndex: PropertyTable.RowIndex, propertySig: PropertySig) {
        super.init(definingType: definingType, tableRowIndex: tableRowIndex, propertySig: propertySig)
    }
}

extension Property: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Property, rhs: Property) -> Bool { lhs === rhs }
}
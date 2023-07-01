import DotNetMDFormat

public final class Event {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: Table<DotNetMDFormat.Event>.RowIndex

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.Event>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { definingTypeImpl.assemblyImpl }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: DotNetMDFormat.Event { database.tables.event[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }

    private lazy var _handlerType = Result { assemblyImpl.resolve(tableRow.eventType)! }
    public var handlerType: BoundType { get throws { try _handlerType.get() } }

    private struct Accessors {
        var add: Method?
        var remove: Method?
        var fire: Method?
        var others: [Method] = []
    }

    private lazy var accessors = Result { [self] in
        var accessors = Accessors()
        for entry in definingTypeImpl.getAccessors(token: MetadataToken(tableRowIndex)) {
            if entry.attributes == .addOn { accessors.add = entry.method }
            else if entry.attributes == .removeOn { accessors.remove = entry.method }
            else if entry.attributes == .fire { accessors.fire = entry.method }
            else if entry.attributes == .other { accessors.others.append(entry.method) }
            else { fatalError("Unexpected event accessor attributes value") }
        }
        return accessors
    }

    public var addAccessor: Method? { get throws { try accessors.get().add } }
    public var removeAccessor: Method? { get throws { try accessors.get().remove } }
    public var fireAccessor: Method? { get throws { try accessors.get().fire } }
    public var otherAccessors: [Method] { get throws { try accessors.get().others } }

    private var anyAccessor: Method? {
        get throws {
            let accessors = try self.accessors.get()
            return accessors.add ?? accessors.remove ?? accessors.fire ?? accessors.others.first
        }
    }

    // CLS adds some uniformity guarantees:
    // §II.22.28 "All methods for a given Property or Event shall have the same accessibility"
    public var visibility: Visibility { get throws { try anyAccessor?.visibility ?? .public } }
}
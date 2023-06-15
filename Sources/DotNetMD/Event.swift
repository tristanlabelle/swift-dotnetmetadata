import DotNetMDPhysical

public final class Event {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: Table<DotNetMDPhysical.Event>.RowIndex

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDPhysical.Event>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { definingTypeImpl.assemblyImpl }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: DotNetMDPhysical.Event { database.tables.event[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }

    public private(set) lazy var type: BoundType = assemblyImpl.resolve(tableRow.eventType)!

    private struct Accessors {
        var add: Method?
        var remove: Method?
        var fire: Method?
        var others: [Method] = []
    }

    private lazy var accessors: Accessors = { [self] in
        var accessors = Accessors()
        for entry in definingTypeImpl.getAccessors(token: MetadataToken(tableRowIndex)) {
            if entry.attributes == .addOn { accessors.add = entry.method }
            else if entry.attributes == .removeOn { accessors.remove = entry.method }
            else if entry.attributes == .fire { accessors.fire = entry.method }
            else if entry.attributes == .other { accessors.others.append(entry.method) }
            else { fatalError("Unexpected event accessor attributes value") }
        }
        return accessors
    }()

    public var add: Method? { accessors.add }
    public var remove: Method? { accessors.remove }
    public var fire: Method? { accessors.fire }
    public var otherAccessors: [Method] { accessors.others }

    public var visibility: Visibility {
        (add ?? remove ?? fire ?? otherAccessors.first)?.visibility ?? .public
    }
}
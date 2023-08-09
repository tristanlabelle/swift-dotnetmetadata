import DotNetMetadataFormat

public final class Event: Member {
    public static let addAccessorPrefix = "add_"
    public static let removeAccessorPrefix = "remove_"
    public static let raiseAccessorPrefix = "raise_"

    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: EventTable.RowIndex

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: EventTable.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public override var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: MetadataAssemblyImpl { definingTypeImpl.assemblyImpl }
    internal var moduleFile: ModuleFile { definingTypeImpl.moduleFile }
    private var tableRow: EventTable.Row { moduleFile.eventTable[tableRowIndex] }

    public override var name: String { moduleFile.resolve(tableRow.name) }

    private lazy var _handlerType = Result { assemblyImpl.resolveOptionalBoundType(tableRow.eventType, typeContext: definingType)! }
    public var handlerType: BoundType { get throws { try _handlerType.get() } }

    private struct Accessors {
        var add: Method?
        var remove: Method?
        var fire: Method?
        var others: [Method] = []
    }

    private lazy var accessors = Result { [self] in
        var accessors = Accessors()
        for entry in definingTypeImpl.getAccessors(owner: .event(tableRowIndex)) {
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
        guard let accessors = try? self.accessors.get() else { return nil }
        return accessors.add ?? accessors.remove ?? accessors.fire ?? accessors.others.first
    }

    // CLS adds some uniformity guarantees:
    // §II.22.28 "All methods for a given Property or Event shall have the same accessibility"
    public override var visibility: Visibility { anyAccessor?.visibility ?? .public }
    public override var isStatic: Bool { anyAccessor?.isStatic ?? false }

    public private(set) lazy var attributes: [Attribute] = {
        assemblyImpl.getAttributes(owner: .event(tableRowIndex))
    }()
}

extension Event: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Event, rhs: Event) -> Bool { lhs === rhs }
}
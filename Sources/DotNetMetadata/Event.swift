import DotNetMetadataFormat

public final class Event: Member {
    public static let addAccessorPrefix = "add_"
    public static let removeAccessorPrefix = "remove_"
    public static let raiseAccessorPrefix = "raise_"

    internal let tableRowIndex: EventTable.RowIndex
    private var tableRow: EventTable.Row { moduleFile.eventTable[tableRowIndex] }
    private var flags: EventAttributes { tableRow.eventFlags }

    init(definingType: TypeDefinition, tableRowIndex: EventTable.RowIndex) {
        self.tableRowIndex = tableRowIndex
        super.init(definingType: definingType)
    }

    internal override func resolveName() -> String { moduleFile.resolve(tableRow.name) }
    public override var nameKind: NameKind { flags.nameKind }

    private lazy var _handlerType = Result { try assembly.resolveOptionalBoundType(tableRow.eventType, typeContext: definingType)! }
    public var handlerType: BoundType { get throws { try _handlerType.get() } }

    private struct Accessors {
        var add: Method?
        var remove: Method?
        var fire: Method?
        var others: [Method] = []
    }

    private lazy var accessors = Result { [self] in
        var accessors = Accessors()
        for entry in definingType.getAccessors(owner: .event(tableRowIndex)) {
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

    // Assume all accessors are consistently static or instance
    public override var isStatic: Bool { anyAccessor?.isStatic ?? false }
    public var hasPublicAddRemoveAccessors: Bool {
        (try? addAccessor)?.isPublic == true && (try? removeAccessor)?.isPublic != nil
    }

    public private(set) lazy var attributes: [Attribute] = {
        assembly.getAttributes(owner: .event(tableRowIndex))
    }()
}

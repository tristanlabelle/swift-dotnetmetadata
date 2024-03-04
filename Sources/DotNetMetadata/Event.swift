import DotNetMetadataFormat

public final class Event: Member {
    public static let addAccessorPrefix = "add_"
    public static let removeAccessorPrefix = "remove_"
    public static let raiseAccessorPrefix = "raise_"

    internal let tableRowIndex: TableRowIndex // in Event table
    private var tableRow: EventTable.Row { moduleFile.eventTable[tableRowIndex] }
    private var flags: EventAttributes { tableRow.eventFlags }

    init(definingType: TypeDefinition, tableRowIndex: TableRowIndex) {
        self.tableRowIndex = tableRowIndex
        super.init(definingType: definingType)
    }

    public override var metadataToken: MetadataToken { .init(tableID: .event, rowIndex: tableRowIndex) }
    internal override func resolveName() -> String { moduleFile.resolve(tableRow.name) }
    public override var nameKind: NameKind { flags.nameKind }
    // Assume all accessors are consistently static or instance
    public override var isStatic: Bool { anyAccessor?.isStatic ?? false }
    public override var attributeTarget: AttributeTargets { .event }
    internal override var attributesKeyTag: CodedIndices.HasCustomAttribute.Tag { .event }

    private lazy var _handlerType = Result {
        guard let boundType = try assembly.resolveTypeDefOrRefToBoundType(tableRow.eventType, typeContext: definingType),
            let delegateDefinition = boundType.definition as? DelegateDefinition else { throw InvalidFormatError.tableConstraint }
        return delegateDefinition.bind(genericArgs: boundType.genericArgs)
    }
    public var handlerType: BoundDelegate { get throws { try _handlerType.get() } }

    private struct Accessors {
        var add: Method?
        var remove: Method?
        var fire: Method?
        var others: [Method] = []
    }

    private var cachedAccessors: Accessors?
    private var accessors: Accessors { get throws {
        cachedAccessors.lazyInit {
            var accessors = Accessors()
            for entry in definingType.getAccessors(owner: .init(tag: .event, rowIndex: tableRowIndex)) {
                if entry.attributes == .addOn { accessors.add = entry.method }
                else if entry.attributes == .removeOn { accessors.remove = entry.method }
                else if entry.attributes == .fire { accessors.fire = entry.method }
                else if entry.attributes == .other { accessors.others.append(entry.method) }
                else { fatalError("Unexpected event accessor attributes value") }
            }
            return accessors
        }
    } }

    public var addAccessor: Method? { get throws { try accessors.add } }
    public var removeAccessor: Method? { get throws { try accessors.remove } }
    public var fireAccessor: Method? { get throws { try accessors.fire } }
    public var otherAccessors: [Method] { get throws { try accessors.others } }

    private var anyAccessor: Method? {
        guard let accessors = try? self.accessors else { return nil }
        return accessors.add ?? accessors.remove ?? accessors.fire ?? accessors.others.first
    }

    public var hasPublicAddRemoveAccessors: Bool {
        (try? addAccessor)?.isPublic == true && (try? removeAccessor)?.isPublic != nil
    }
}

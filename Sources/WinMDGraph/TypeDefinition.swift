import WinMD

public class TypeDefinition {
    public unowned let assembly: Assembly
    private let tableRowIndex: Table<WinMD.TypeDef>.RowIndex
    internal var context: MetadataContext { assembly.context }
    internal var database: Database { assembly.database }

    init(assembly: Assembly, tableRowIndex: Table<WinMD.TypeDef>.RowIndex) {
        self.assembly = assembly
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.TypeDef { database.tables.typeDef[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.typeName) }
    public var namespace: String { database.heaps.resolve(tableRow.typeNamespace) }
    public var visibility: Visibility {
        switch tableRow.flags.intersection(.visibilityMask) {
            case .public: return .public
            case .notPublic: return .assembly
            case .nestedFamily: return .family
            case .nestedFamORAssem: return .familyOrAssembly
            case .nestedFamANDAssem: return .familyAndAssembly
            case .nestedAssembly: return .assembly
            case .nestedPrivate: return .private
            default: fatalError()
        }
    }

    public var isAbstract: Bool { tableRow.flags.contains(TypeAttributes.abstract) }
    public var isSealed: Bool { tableRow.flags.contains(TypeAttributes.sealed) }

    public private(set) lazy var fullName: String = {
        let ns = namespace
        return ns.isEmpty ? name : "\(ns).\(name)"
    }()

    public private(set) lazy var genericParams: [GenericParam] = {
        var result: [GenericParam] = []
        var genericParamRowIndex = database.tables.genericParam.find(primaryKey: MetadataToken(tableRowIndex), secondaryKey: 0)
            ?? database.tables.genericParam.endIndex
        while genericParamRowIndex < database.tables.genericParam.endIndex {
            let genericParam = database.tables.genericParam[genericParamRowIndex]
            guard genericParam.primaryKey == MetadataToken(tableRowIndex) && genericParam.number == result.count else { break }
            result.append(GenericParam(definingType: self, tableRowIndex: genericParamRowIndex))
            genericParamRowIndex = database.tables.genericParam.index(after: genericParamRowIndex)
        }
        return result
    }()

    public private(set) lazy var base: TypeDefinition? = {
        assembly.resolve(tableRow.extends)
    }()

    public private(set) lazy var methods: [Method] = {
        getChildRowRange(parent: database.tables.typeDef,
            parentRowIndex: tableRowIndex,
            childTable: database.tables.methodDef,
            childSelector: { $0.methodList }).map {
            Method(definingType: self, tableRowIndex: $0)
        }
    }()

    public func findSingleMethod(name: String) -> Method? {
        methods.single { $0.name == name }
    }

    public private(set) lazy var fields: [Field] = {
        getChildRowRange(parent: database.tables.typeDef,
            parentRowIndex: tableRowIndex,
            childTable: database.tables.field,
            childSelector: { $0.fieldList }).map {
            Field(definingType: self, tableRowIndex: $0)
        }
    }()

    public func findField(name: String) -> Field? {
        fields.first { $0.name == name }
    }

    public private(set) lazy var properties: [Property] = {
        guard let propertyMapRowIndex = assembly.findPropertyMap(forTypeDef: tableRowIndex) else { return [] }
        return getChildRowRange(parent: database.tables.propertyMap,
            parentRowIndex: propertyMapRowIndex,
            childTable: database.tables.property,
            childSelector: { $0.propertyList }).map {
            Property(definingType: self, tableRowIndex: $0)
        }
    }()

    public func findProperty(name: String) -> Property? {
        properties.first { $0.name == name }
    }

    public private(set) lazy var events: [Event] = {
        guard let eventMapRowIndex: Table<EventMap>.RowIndex = assembly.findEventMap(forTypeDef: tableRowIndex) else { return [] }
        return getChildRowRange(parent: database.tables.eventMap,
            parentRowIndex: eventMapRowIndex,
            childTable: database.tables.event,
            childSelector: { $0.eventList }).map {
            Event(definingType: self, tableRowIndex: $0)
        }
    }()

    public func findEvent(name: String) -> Event? {
        events.first { $0.name == name }
    }
}
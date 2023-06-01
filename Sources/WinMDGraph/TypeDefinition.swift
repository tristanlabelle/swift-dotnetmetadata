import WinMD

public class TypeDefinition {
    public var assembly: Assembly { fatalError() }

    public var name: String { fatalError() }
    public var namespace: String { fatalError() }
    internal var metadataFlags: WinMD.TypeAttributes { fatalError() }
    public var genericParams: [GenericParam] { fatalError() }
    public var base: TypeDefinition? { fatalError() }
    public var fields: [Field]  { fatalError() }
    public var methods: [Method] { fatalError() }
    public var properties: [Property] { fatalError() }
    public var events: [Event] { fatalError() }
    
    public private(set) lazy var fullName: String = {
        let ns = namespace
        return ns.isEmpty ? name : "\(ns).\(name)"
    }()
    
    public var visibility: Visibility {
        switch metadataFlags.intersection(.visibilityMask) {
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
    
    public var isAbstract: Bool { metadataFlags.contains(TypeAttributes.abstract) }
    public var isSealed: Bool { metadataFlags.contains(TypeAttributes.sealed) }

    public func findSingleMethod(name: String) -> Method? { methods.single { $0.name == name } }
    public func findField(name: String) -> Field? { fields.first { $0.name == name } }
    public func findProperty(name: String) -> Property? { properties.first { $0.name == name } }
    public func findEvent(name: String) -> Event? { events.first { $0.name == name } }
}

public class TypeDefinitionFromMetadata: TypeDefinition {
    internal unowned let assemblyFromMetadata: AssemblyFromMetadata
    public override var assembly: Assembly { assemblyFromMetadata }
    private let tableRowIndex: Table<WinMD.TypeDef>.RowIndex
    internal var context: MetadataContext { assemblyFromMetadata.context }
    internal var database: Database { assemblyFromMetadata.database }

    init(assembly: AssemblyFromMetadata, tableRowIndex: Table<WinMD.TypeDef>.RowIndex) {
        self.assemblyFromMetadata = assembly
        self.tableRowIndex = tableRowIndex
    }

    private var tableRow: WinMD.TypeDef { database.tables.typeDef[tableRowIndex] }

    public override var name: String { database.heaps.resolve(tableRow.typeName) }
    public override var namespace: String { database.heaps.resolve(tableRow.typeNamespace) }

    internal override var metadataFlags: WinMD.TypeAttributes { tableRow.flags }

    private lazy var _genericParams: [GenericParam] = {
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
    public override var genericParams: [GenericParam] { _genericParams }

    private lazy var _base: TypeDefinition? = {
        assemblyFromMetadata.resolve(tableRow.extends)
    }()
    public override var base: TypeDefinition? { _base }

    private lazy var _methods: [Method] = {
        getChildRowRange(parent: database.tables.typeDef,
            parentRowIndex: tableRowIndex,
            childTable: database.tables.methodDef,
            childSelector: { $0.methodList }).map {
            Method(definingType: self, tableRowIndex: $0)
        }
    }()
    public override var methods: [Method] { _methods }

    private lazy var _fields: [Field] = {
        getChildRowRange(parent: database.tables.typeDef,
            parentRowIndex: tableRowIndex,
            childTable: database.tables.field,
            childSelector: { $0.fieldList }).map {
            Field(definingType: self, tableRowIndex: $0)
        }
    }()
    public override var fields: [Field] { _fields }

    private lazy var _properties: [Property] = {
        guard let propertyMapRowIndex = assemblyFromMetadata.findPropertyMap(forTypeDef: tableRowIndex) else { return [] }
        return getChildRowRange(parent: database.tables.propertyMap,
            parentRowIndex: propertyMapRowIndex,
            childTable: database.tables.property,
            childSelector: { $0.propertyList }).map {
            Property(definingType: self, tableRowIndex: $0)
        }
    }()
    public override var properties: [Property] { _properties }

    private lazy var _events: [Event] = {
        guard let eventMapRowIndex: Table<EventMap>.RowIndex = assemblyFromMetadata.findEventMap(forTypeDef: tableRowIndex) else { return [] }
        return getChildRowRange(parent: database.tables.eventMap,
            parentRowIndex: eventMapRowIndex,
            childTable: database.tables.event,
            childSelector: { $0.eventList }).map {
            Event(definingType: self, tableRowIndex: $0)
        }
    }()
    public override var events: [Event] { _events }
}
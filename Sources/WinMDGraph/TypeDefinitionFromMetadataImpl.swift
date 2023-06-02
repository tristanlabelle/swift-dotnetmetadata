import WinMD

public class TypeDefinitionFromMetadataImpl: TypeDefinitionImpl {
    internal unowned var parent: TypeDefinition!
    internal unowned let assemblyImpl: AssemblyFromMetadataImpl
    private let tableRowIndex: Table<WinMD.TypeDef>.RowIndex

    init(assemblyImpl: AssemblyFromMetadataImpl, tableRowIndex: Table<WinMD.TypeDef>.RowIndex) {
        self.assemblyImpl = assemblyImpl
        self.tableRowIndex = tableRowIndex
    }

    func initialize(parent: TypeDefinition) {
        self.parent = parent
    }
    
    internal var assembly: Assembly { parent.assembly }
    internal var database: Database { assemblyImpl.database }

    private var tableRow: WinMD.TypeDef { database.tables.typeDef[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.typeName) }
    public var namespace: String { database.heaps.resolve(tableRow.typeNamespace) }

    internal var metadataFlags: WinMD.TypeAttributes { tableRow.flags }

    private lazy var _genericParams: [GenericParam] = { [self] in
        var result: [GenericParam] = []
        var genericParamRowIndex = database.tables.genericParam.find(primaryKey: MetadataToken(tableRowIndex), secondaryKey: 0)
            ?? database.tables.genericParam.endIndex
        while genericParamRowIndex < database.tables.genericParam.endIndex {
            let genericParam = database.tables.genericParam[genericParamRowIndex]
            guard genericParam.primaryKey == MetadataToken(tableRowIndex) && genericParam.number == result.count else { break }
            result.append(GenericParam(definingTypeImpl: self, tableRowIndex: genericParamRowIndex))
            genericParamRowIndex = database.tables.genericParam.index(after: genericParamRowIndex)
        }
        return result
    }()
    public var genericParams: [GenericParam] { _genericParams }

    private lazy var _base: TypeDefinition? = {
        assemblyImpl.resolve(tableRow.extends)
    }()
    public var base: TypeDefinition? { _base }

    private lazy var _methods: [Method] = {
        getChildRowRange(parent: database.tables.typeDef,
            parentRowIndex: tableRowIndex,
            childTable: database.tables.methodDef,
            childSelector: { $0.methodList }).map {
            Method(definingTypeImpl: self, tableRowIndex: $0)
        }
    }()
    public var methods: [Method] { _methods }

    private lazy var _fields: [Field] = {
        getChildRowRange(parent: database.tables.typeDef,
            parentRowIndex: tableRowIndex,
            childTable: database.tables.field,
            childSelector: { $0.fieldList }).map {
            Field(definingTypeImpl: self, tableRowIndex: $0)
        }
    }()
    public var fields: [Field] { _fields }

    private lazy var _properties: [Property] = {
        guard let propertyMapRowIndex = assemblyImpl.findPropertyMap(forTypeDef: tableRowIndex) else { return [] }
        return getChildRowRange(parent: database.tables.propertyMap,
            parentRowIndex: propertyMapRowIndex,
            childTable: database.tables.property,
            childSelector: { $0.propertyList }).map {
            Property(definingTypeImpl: self, tableRowIndex: $0)
        }
    }()
    public var properties: [Property] { _properties }

    private lazy var _events: [Event] = {
        guard let eventMapRowIndex: Table<EventMap>.RowIndex = assemblyImpl.findEventMap(forTypeDef: tableRowIndex) else { return [] }
        return getChildRowRange(parent: database.tables.eventMap,
            parentRowIndex: eventMapRowIndex,
            childTable: database.tables.event,
            childSelector: { $0.eventList }).map {
            Event(definingTypeImpl: self, tableRowIndex: $0)
        }
    }()
    public var events: [Event] { _events }
}
import DotNetMDFormat

extension TypeDefinition {
    final class MetadataImpl: Impl {
        internal private(set) unowned var owner: TypeDefinition!
        internal unowned let assemblyImpl: Assembly.MetadataImpl
        internal let tableRowIndex: Table<DotNetMDFormat.TypeDef>.RowIndex

        init(assemblyImpl: Assembly.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.TypeDef>.RowIndex) {
            self.assemblyImpl = assemblyImpl
            self.tableRowIndex = tableRowIndex
        }

        func initialize(owner: TypeDefinition) {
            self.owner = owner
        }

        internal var assembly: Assembly { assemblyImpl.owner }
        internal var database: Database { assemblyImpl.database }

        private var tableRow: DotNetMDFormat.TypeDef { database.tables.typeDef[tableRowIndex] }

        internal var kind: TypeDefinitionKind {
            // Figuring out the kind requires checking the base type,
            // but we must be careful to not look up any other `TypeDefinition`
            // instances since they might not have been created yet.
            // For safety, implement this at the physical layer.
            database.getTypeDefinitionKind(tableRow, isMscorlib: assembly.name == Mscorlib.name)
        }

        public var name: String { database.heaps.resolve(tableRow.typeName) }
        public var namespace: String { database.heaps.resolve(tableRow.typeNamespace) }

        internal var metadataFlags: DotNetMDFormat.TypeAttributes { tableRow.flags }

        public private(set) lazy var genericParams: [GenericTypeParam] = { [self] in
            var result: [GenericTypeParam] = []
            var genericParamRowIndex = database.tables.genericParam.find(primaryKey: MetadataToken(tableRowIndex), secondaryKey: 0)
                ?? database.tables.genericParam.endIndex
            while genericParamRowIndex < database.tables.genericParam.endIndex {
                let genericParam = database.tables.genericParam[genericParamRowIndex]
                guard genericParam.primaryKey == MetadataToken(tableRowIndex) && genericParam.number == result.count else { break }
                result.append(GenericTypeParam(definingTypeImpl: self, tableRowIndex: genericParamRowIndex))
                genericParamRowIndex = database.tables.genericParam.index(after: genericParamRowIndex)
            }
            return result
        }()

        public private(set) lazy var base: BoundType? = assemblyImpl.resolve(tableRow.extends)

        public private(set) lazy var baseInterfaces: [BaseInterface] = { [self] in
            guard let firstInterfaceImplRowIndex = database.tables.interfaceImpl.findFirst(primaryKey: MetadataToken(tableRowIndex)) else { return [] }

            var interfaceImplRowIndex = firstInterfaceImplRowIndex
            var result: [BaseInterface] = []
            while interfaceImplRowIndex != database.tables.interfaceImpl.endIndex {
                let interfaceImpl = database.tables.interfaceImpl[interfaceImplRowIndex]
                guard interfaceImpl.primaryKey == MetadataToken(tableRowIndex) else { break }
                result.append(BaseInterface(inheritingTypeImpl: self, tableRowIndex: interfaceImplRowIndex))
                interfaceImplRowIndex = database.tables.interfaceImpl.index(after: interfaceImplRowIndex)
            }

            return result
        }()

        public private(set) lazy var methods: [Method] = {
            getChildRowRange(parent: database.tables.typeDef,
                parentRowIndex: tableRowIndex,
                childTable: database.tables.methodDef,
                childSelector: { $0.methodList }).map {
                Method.create(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var fields: [Field] = {
            getChildRowRange(parent: database.tables.typeDef,
                parentRowIndex: tableRowIndex,
                childTable: database.tables.field,
                childSelector: { $0.fieldList }).map {
                Field(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var properties: [Property] = {
            guard let propertyMapRowIndex = assemblyImpl.findPropertyMap(forTypeDef: tableRowIndex) else { return [] }
            return getChildRowRange(parent: database.tables.propertyMap,
                parentRowIndex: propertyMapRowIndex,
                childTable: database.tables.property,
                childSelector: { $0.propertyList }).map {
                Property.create(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var events: [Event] = {
            guard let eventMapRowIndex: Table<EventMap>.RowIndex = assemblyImpl.findEventMap(forTypeDef: tableRowIndex) else { return [] }
            return getChildRowRange(parent: database.tables.eventMap,
                parentRowIndex: eventMapRowIndex,
                childTable: database.tables.event,
                childSelector: { $0.eventList }).map {
                Event(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        internal func getAccessors(token: MetadataToken) -> [(method: Method, attributes: MethodSemanticsAttributes)] {
            var result = [(method: Method, attributes: MethodSemanticsAttributes)].init()
            guard var semanticsRowIndex = database.tables.methodSemantics.findFirst(primaryKey: token) else { return result }
            while semanticsRowIndex != database.tables.methodSemantics.endIndex {
                let semanticsRow = database.tables.methodSemantics[semanticsRowIndex]
                guard semanticsRow.primaryKey == token else { break }

                let method = methods.first { $0.tableRowIndex == semanticsRow.method }!
                result.append((method, semanticsRow.semantics))
                semanticsRowIndex = database.tables.methodSemantics.index(after: semanticsRowIndex)
            }

            return result
        }
    }
}
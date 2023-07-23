import DotNetMDFormat

extension TypeDefinition {
    final class MetadataImpl: Impl {
        internal private(set) unowned var owner: TypeDefinition!
        internal unowned let assemblyImpl: Assembly.MetadataImpl
        internal let tableRowIndex: TypeDefTable.RowIndex

        init(assemblyImpl: Assembly.MetadataImpl, tableRowIndex: TypeDefTable.RowIndex) {
            self.assemblyImpl = assemblyImpl
            self.tableRowIndex = tableRowIndex
        }

        func initialize(owner: TypeDefinition) {
            self.owner = owner
        }

        internal var assembly: Assembly { assemblyImpl.owner }
        internal var database: Database { assemblyImpl.database }

        private var tableRow: TypeDefTable.Row { database.tables.typeDef[tableRowIndex] }

        internal var kind: TypeDefinitionKind {
            // Figuring out the kind requires checking the base type,
            // but we must be careful to not look up any other `TypeDefinition`
            // instances since they might not have been created yet.
            // For safety, implement this at the physical layer.
            database.getTypeDefinitionKind(tableRow, isMscorlib: assembly.name == Mscorlib.name)
        }

        public var name: String { database.heaps.resolve(tableRow.typeName) }

        public var namespace: String? {
            let tableRow = tableRow
            // Normally, no namespace is represented by a zero string heap index
            guard tableRow.typeNamespace.value != 0 else { return nil }
            let value = database.heaps.resolve(tableRow.typeNamespace)
            return value.isEmpty ? nil : value
        }

        internal var metadataAttributes: DotNetMDFormat.TypeAttributes { tableRow.flags }

        public private(set) lazy var classLayout: ClassLayoutData = {
            guard let classLayoutRowIndex = database.tables.classLayout.findAny(primaryKey: tableRowIndex.metadataToken.tableKey)
            else { return ClassLayoutData(0, 0) }

            let classLayoutRow = database.tables.classLayout[classLayoutRowIndex]
            return ClassLayoutData(pack: classLayoutRow.packingSize, size: classLayoutRow.classSize)
        }()

        public private(set) lazy var enclosingType: TypeDefinition? = {
            guard let nestedClassRowIndex = database.tables.nestedClass.findAny(primaryKey: MetadataToken(tableRowIndex).tableKey) else { return nil }
            guard let enclosingTypeDefRowIndex = database.tables.nestedClass[nestedClassRowIndex].enclosingClass else { return nil }
            return assemblyImpl.resolve(enclosingTypeDefRowIndex)
        }()

        public private(set) lazy var genericParams: [GenericTypeParam] = {
            database.tables.genericParam.findAll(primaryKey: tableRowIndex.metadataToken.tableKey) {
                rowIndex, _ in GenericTypeParam(definingTypeImpl: self, tableRowIndex: rowIndex)
            }
        }()

        public private(set) lazy var base: BoundType? = assemblyImpl.resolveOptionalBoundType(tableRow.extends)

        public private(set) lazy var baseInterfaces: [BaseInterface] = {
            database.tables.interfaceImpl.findAll(primaryKey: tableRowIndex.metadataToken.tableKey) {
                rowIndex, _ in BaseInterface(inheritingTypeImpl: self, tableRowIndex: rowIndex)
            }
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
            guard let eventMapRowIndex: EventMapTable.RowIndex = assemblyImpl.findEventMap(forTypeDef: tableRowIndex) else { return [] }
            return getChildRowRange(parent: database.tables.eventMap,
                parentRowIndex: eventMapRowIndex,
                childTable: database.tables.event,
                childSelector: { $0.eventList }).map {
                Event(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var attributes: [Attribute] = {
            assemblyImpl.getAttributes(owner: .typeDef(tableRowIndex))
        }()

        internal func getAccessors(owner: HasSemantics) -> [(method: Method, attributes: MethodSemanticsAttributes)] {
            database.tables.methodSemantics.findAll(primaryKey: owner.metadataToken.tableKey) { rowIndex, row in 
                let method = methods.first { $0.tableRowIndex == row.method }!
                return (method, row.semantics)
            }
        }
    }
}
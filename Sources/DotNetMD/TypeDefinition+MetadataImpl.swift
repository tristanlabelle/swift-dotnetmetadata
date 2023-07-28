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
        internal var moduleFile: ModuleFile { assemblyImpl.moduleFile }

        private var tableRow: TypeDefTable.Row { moduleFile.tables.typeDef[tableRowIndex] }

        internal var kind: TypeDefinitionKind {
            // Figuring out the kind requires checking the base type,
            // but we must be careful to not look up any other `TypeDefinition`
            // instances since they might not have been created yet.
            // For safety, implement this at the physical layer.
            moduleFile.getTypeDefinitionKind(tableRow, isMscorlib: assembly.name == Mscorlib.name)
        }

        public var name: String { moduleFile.heaps.resolve(tableRow.typeName) }

        public var namespace: String? {
            let tableRow = tableRow
            // Normally, no namespace is represented by a zero string heap index
            guard tableRow.typeNamespace.value != 0 else { return nil }
            let value = moduleFile.heaps.resolve(tableRow.typeNamespace)
            return value.isEmpty ? nil : value
        }

        internal var metadataAttributes: DotNetMDFormat.TypeAttributes { tableRow.flags }

        public private(set) lazy var classLayout: ClassLayoutData = {
            guard let classLayoutRowIndex = moduleFile.tables.classLayout.findAny(primaryKey: tableRowIndex.metadataToken.tableKey)
            else { return ClassLayoutData(0, 0) }

            let classLayoutRow = moduleFile.tables.classLayout[classLayoutRowIndex]
            return ClassLayoutData(pack: classLayoutRow.packingSize, size: classLayoutRow.classSize)
        }()

        public private(set) lazy var enclosingType: TypeDefinition? = {
            guard let nestedClassRowIndex = moduleFile.tables.nestedClass.findAny(primaryKey: MetadataToken(tableRowIndex).tableKey) else { return nil }
            guard let enclosingTypeDefRowIndex = moduleFile.tables.nestedClass[nestedClassRowIndex].enclosingClass else { return nil }
            return assemblyImpl.resolve(enclosingTypeDefRowIndex)
        }()

        public private(set) lazy var genericParams: [GenericTypeParam] = {
            moduleFile.tables.genericParam.findAll(primaryKey: tableRowIndex.metadataToken.tableKey).map {
                GenericTypeParam(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var base: BoundType? = assemblyImpl.resolveOptionalBoundType(tableRow.extends)

        public private(set) lazy var baseInterfaces: [BaseInterface] = {
            moduleFile.tables.interfaceImpl.findAll(primaryKey: tableRowIndex.metadataToken.tableKey).map {
                BaseInterface(inheritingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var methods: [Method] = {
            getChildRowRange(parent: moduleFile.tables.typeDef,
                parentRowIndex: tableRowIndex,
                childTable: moduleFile.tables.methodDef,
                childSelector: { $0.methodList }).map {
                Method.create(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var fields: [Field] = {
            getChildRowRange(parent: moduleFile.tables.typeDef,
                parentRowIndex: tableRowIndex,
                childTable: moduleFile.tables.field,
                childSelector: { $0.fieldList }).map {
                Field(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var properties: [Property] = {
            guard let propertyMapRowIndex = assemblyImpl.findPropertyMap(forTypeDef: tableRowIndex) else { return [] }
            return getChildRowRange(parent: moduleFile.tables.propertyMap,
                parentRowIndex: propertyMapRowIndex,
                childTable: moduleFile.tables.property,
                childSelector: { $0.propertyList }).map {
                Property.create(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var events: [Event] = {
            guard let eventMapRowIndex: EventMapTable.RowIndex = assemblyImpl.findEventMap(forTypeDef: tableRowIndex) else { return [] }
            return getChildRowRange(parent: moduleFile.tables.eventMap,
                parentRowIndex: eventMapRowIndex,
                childTable: moduleFile.tables.event,
                childSelector: { $0.eventList }).map {
                Event(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var attributes: [Attribute] = {
            assemblyImpl.getAttributes(owner: .typeDef(tableRowIndex))
        }()

        public private(set) lazy var nestedTypes: [TypeDefinition] = {
            moduleFile.tables.nestedClass.findAllNested(enclosing: tableRowIndex).map {
                let nestedTypeRowIndex = moduleFile.tables.nestedClass[$0].nestedClass!
                return assemblyImpl.resolve(nestedTypeRowIndex)
            }
        }()

        internal func getAccessors(owner: HasSemantics) -> [(method: Method, attributes: MethodSemanticsAttributes)] {
            moduleFile.tables.methodSemantics.findAll(primaryKey: owner.metadataToken.tableKey).map {
                let row = moduleFile.tables.methodSemantics[$0]
                let method = methods.first { $0.tableRowIndex == row.method }!
                return (method, row.semantics)
            }
        }
    }
}
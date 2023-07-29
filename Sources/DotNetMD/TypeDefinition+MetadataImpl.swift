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

        private var tableRow: TypeDefTable.Row { moduleFile.typeDefTable[tableRowIndex] }

        internal var kind: TypeDefinitionKind {
            // Figuring out the kind requires checking the base type,
            // but we must be careful to not look up any other `TypeDefinition`
            // instances since they might not have been created yet.
            // For safety, implement this at the physical layer.
            moduleFile.getTypeDefinitionKind(tableRow, isMscorlib: assembly.name == Mscorlib.name)
        }

        public var name: String { moduleFile.resolve(tableRow.typeName) }

        public var namespace: String? {
            let tableRow = tableRow
            // Normally, no namespace is represented by a zero string heap index
            guard tableRow.typeNamespace.value != 0 else { return nil }
            let value = moduleFile.resolve(tableRow.typeNamespace)
            return value.isEmpty ? nil : value
        }

        internal var metadataAttributes: DotNetMDFormat.TypeAttributes { tableRow.flags }

        public private(set) lazy var classLayout: ClassLayoutData = {
            guard let classLayoutRowIndex = moduleFile.classLayoutTable.findAny(primaryKey: tableRowIndex.metadataToken.tableKey)
            else { return ClassLayoutData(0, 0) }

            let classLayoutRow = moduleFile.classLayoutTable[classLayoutRowIndex]
            return ClassLayoutData(pack: classLayoutRow.packingSize, size: classLayoutRow.classSize)
        }()

        public private(set) lazy var enclosingType: TypeDefinition? = {
            guard let nestedClassRowIndex = moduleFile.nestedClassTable.findAny(primaryKey: MetadataToken(tableRowIndex).tableKey) else { return nil }
            guard let enclosingTypeDefRowIndex = moduleFile.nestedClassTable[nestedClassRowIndex].enclosingClass else { return nil }
            return assemblyImpl.resolve(enclosingTypeDefRowIndex)
        }()

        public private(set) lazy var genericParams: [GenericTypeParam] = {
            moduleFile.genericParamTable.findAll(primaryKey: tableRowIndex.metadataToken.tableKey).map {
                GenericTypeParam(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var base: BoundType? = assemblyImpl.resolveOptionalBoundType(tableRow.extends)

        public private(set) lazy var baseInterfaces: [BaseInterface] = {
            moduleFile.interfaceImplTable.findAll(primaryKey: tableRowIndex.metadataToken.tableKey).map {
                BaseInterface(inheritingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var methods: [Method] = {
            getChildRowRange(parent: moduleFile.typeDefTable,
                parentRowIndex: tableRowIndex,
                childTable: moduleFile.methodDefTable,
                childSelector: { $0.methodList }).map {
                Method.create(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var fields: [Field] = {
            getChildRowRange(parent: moduleFile.typeDefTable,
                parentRowIndex: tableRowIndex,
                childTable: moduleFile.fieldTable,
                childSelector: { $0.fieldList }).map {
                Field(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var properties: [Property] = {
            guard let propertyMapRowIndex = assemblyImpl.findPropertyMap(forTypeDef: tableRowIndex) else { return [] }
            return getChildRowRange(parent: moduleFile.propertyMapTable,
                parentRowIndex: propertyMapRowIndex,
                childTable: moduleFile.propertyTable,
                childSelector: { $0.propertyList }).map {
                Property.create(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var events: [Event] = {
            guard let eventMapRowIndex: EventMapTable.RowIndex = assemblyImpl.findEventMap(forTypeDef: tableRowIndex) else { return [] }
            return getChildRowRange(parent: moduleFile.eventMapTable,
                parentRowIndex: eventMapRowIndex,
                childTable: moduleFile.eventTable,
                childSelector: { $0.eventList }).map {
                Event(definingTypeImpl: self, tableRowIndex: $0)
            }
        }()

        public private(set) lazy var attributes: [Attribute] = {
            assemblyImpl.getAttributes(owner: .typeDef(tableRowIndex))
        }()

        public private(set) lazy var nestedTypes: [TypeDefinition] = {
            moduleFile.nestedClassTable.findAllNested(enclosing: tableRowIndex).map {
                let nestedTypeRowIndex = moduleFile.nestedClassTable[$0].nestedClass!
                return assemblyImpl.resolve(nestedTypeRowIndex)
            }
        }()

        internal func getAccessors(owner: HasSemantics) -> [(method: Method, attributes: MethodSemanticsAttributes)] {
            moduleFile.methodSemanticsTable.findAll(primaryKey: owner.metadataToken.tableKey).map {
                let row = moduleFile.methodSemanticsTable[$0]
                let method = methods.first { $0.tableRowIndex == row.method }!
                return (method, row.semantics)
            }
        }
    }
}
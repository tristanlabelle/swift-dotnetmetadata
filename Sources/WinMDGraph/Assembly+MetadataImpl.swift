import WinMD

/// Implementation for real assemblies based on loaded metadata from a PE file.
extension Assembly {
    final class MetadataImpl: Impl {
        private var assembly: Assembly!
        internal let database: Database
        private let tableRow: WinMD.Assembly

        internal init(database: Database, tableRow: WinMD.Assembly) {
            self.database = database
            self.tableRow = tableRow
        }

        func initialize(owner: Assembly) {
            self.assembly = owner
        }

        public var name: String { database.heaps.resolve(tableRow.name) }
        public var culture: String { database.heaps.resolve(tableRow.culture) }

        public var version: AssemblyVersion {
            .init(
                major: tableRow.majorVersion,
                minor: tableRow.minorVersion,
                buildNumber: tableRow.buildNumber,
                revisionNumber: tableRow.revisionNumber)
        }

        public private(set) lazy var types: [TypeDefinition] = {
            database.tables.typeDef.indices.map { 
                TypeDefinition(
                    assembly: assembly,
                    impl: TypeDefinition.MetadataImpl(assemblyImpl: self, tableRowIndex: $0))
            }
        }()

        internal func resolve(_ codedIndex: TypeDefOrRef) -> TypeDefinition? {
            switch codedIndex {
                case let .typeDef(index):
                    return index == nil ? nil : types[Int(index!.zeroBased)]
                default: fatalError()
            }
        }

        private lazy var propertyMapByTypeDefRowIndex: [Table<TypeDef>.RowIndex: Table<PropertyMap>.RowIndex] = {
            .init(uniqueKeysWithValues: database.tables.propertyMap.indices.map {
                (database.tables.propertyMap[$0].parent!, $0)
            })
        }()

        func findPropertyMap(forTypeDef typeDefRowIndex: Table<TypeDef>.RowIndex) -> Table<PropertyMap>.RowIndex? {
            propertyMapByTypeDefRowIndex[typeDefRowIndex]
        }

        private lazy var eventMapByTypeDefRowIndex: [Table<TypeDef>.RowIndex: Table<EventMap>.RowIndex] = {
            .init(uniqueKeysWithValues: database.tables.eventMap.indices.map {
                (database.tables.eventMap[$0].parent!, $0)
            })
        }()

        func findEventMap(forTypeDef typeDefRowIndex: Table<TypeDef>.RowIndex) -> Table<EventMap>.RowIndex? {
            eventMapByTypeDefRowIndex[typeDefRowIndex]
        }
    }
}
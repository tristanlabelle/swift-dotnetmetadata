import WinMD

/// Implementation for real assemblies based on loaded metadata from a PE file.
final class AssemblyFromMetadataImpl: AssemblyImpl {
    private var assembly: Assembly!
    internal let database: Database
    private let tableRow: WinMD.Assembly

    internal init(database: Database, tableRow: WinMD.Assembly) {
        self.database = database
        self.tableRow = tableRow
    }

    func initialize(parent: Assembly) {
        self.assembly = parent
    }

    public var name: String { database.heaps.resolve(tableRow.name) }

    public private(set) lazy var types: [TypeDefinition] = {
        database.tables.typeDef.indices.map { 
            TypeDefinition(
                assembly: assembly,
                impl: TypeDefinitionFromMetadataImpl(assemblyImpl: self, tableRowIndex: $0))
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
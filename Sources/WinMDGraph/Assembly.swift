import WinMD

public class Assembly {
    public var name: String { fatalError() }
    public var types: [TypeDefinition] { fatalError() }
    
    public private(set) lazy var typesByFullName: [String: TypeDefinition] = {
        Dictionary(uniqueKeysWithValues: types.map { ($0.fullName, $0) })
    }()

    public func findTypeDefinition(fullName: String) -> TypeDefinition? {
        typesByFullName[fullName]
    }
}

/// Implementation for real assemblies based on loaded metadata from a PE file.
final class AssemblyFromMetadata: Assembly {
    internal unowned let context: MetadataContext
    internal let database: Database
    private let tableRow: WinMD.Assembly

    internal init(context: MetadataContext, database: Database, tableRow: WinMD.Assembly) {
        self.context = context
        self.database = database
        self.tableRow = tableRow
    }

    public override var name: String { database.heaps.resolve(tableRow.name) }

    private lazy var _types: [TypeDefinition] = {
        database.tables.typeDef.indices.map {
            TypeDefinitionFromMetadata(assembly: self, tableRowIndex: $0)
        }
    }()

    public override var types: [TypeDefinition] { _types }

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
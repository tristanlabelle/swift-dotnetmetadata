import WinMD

public final class Assembly {
    internal unowned let context: MetadataContext
    internal let database: Database
    private let tableRow: WinMD.Assembly

    internal init(context: MetadataContext, database: Database, tableRow: WinMD.Assembly) {
        self.context = context
        self.database = database
        self.tableRow = tableRow
    }

    public var name: String { database.heaps.resolve(tableRow.name) }

    private var lazyTypes: [TypeDefinition]?
    private var types: [TypeDefinition] {
        lazyInit(storage: &lazyTypes) {
            (0 ..< database.tables.typeDef.count).map {
                TypeDefinition(assembly: self, tableRowIndex: .init(zeroBased: $0))
            }
        }
    }

    private var lazyTypesByFullName: [String: TypeDefinition]?
    private var typesByFullName: [String: TypeDefinition] {
        lazyInit(storage: &lazyTypesByFullName) {
            Dictionary(uniqueKeysWithValues: types.map { ($0.fullName, $0) })
        }
    }

    public func findTypeDefinition(fullName: String) -> TypeDefinition? {
        typesByFullName[fullName]
    }

    internal func resolve(_ codedIndex: TypeDefOrRef) -> TypeDefinition? {
        switch codedIndex {
            case let .typeDef(index): return index.isNull ? nil : types[index.zeroBased!]
            default: fatalError()
        }
    }
}
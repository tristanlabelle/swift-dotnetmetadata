import WinMD

public class Assembly {
    internal unowned let context: MetadataContext
    internal let database: Database
    private let tableRow: WinMD.Assembly

    internal init(context: MetadataContext, database: Database, tableRow: WinMD.Assembly) {
        self.context = context
        self.database = database
        self.tableRow = tableRow
    }

    public lazy var name: String = database.heaps.resolve(tableRow.name)

    private lazy var types: [TypeDefinition] = (0 ..< database.tables.typeDef.count).map {
        TypeDefinition(assembly: self, tableRowIndex: .init(zeroBased: $0))
    }

    private lazy var typesByFullName: [String: TypeDefinition] = Dictionary(uniqueKeysWithValues: types.map { ($0.fullName, $0) })

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
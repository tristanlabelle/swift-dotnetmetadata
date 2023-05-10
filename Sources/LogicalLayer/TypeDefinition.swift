public class TypeDefinition {
    unowned let context: MetadataContext
    let database: Database
    let tableRow: TypeDef

    init(context: MetadataContext, database: Database, tableRow: TypeDef) {
        self.context = context
        self.tableRow = tableRow
        self.database = database
    }

    var name: String { database.heaps.resolve(tableRow.typeName) }
    var namespace: String { database.heaps.resolve(tableRow.typeNamespace) }
}
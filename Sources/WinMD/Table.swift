class Table<Row> where Row: TableRow {
    let buffer: UnsafeRawBufferPointer
    let database: Database
    let rowSize: Int

    init(buffer: UnsafeRawBufferPointer, database: Database) {
        self.buffer = buffer
        self.database = database
        self.rowSize = Row.getSize(database: database)
    }

    static var tokenKind: CLI.MetadataTokenKind { Row.tokenKind }
    var count: Int { buffer.count / rowSize }

    subscript(_ index: Int) -> Row {
        let rowBuffer = buffer.sub(offset: index * rowSize, count: rowSize)
        return Row.read(buffer: rowBuffer, database: database)
    }
}

extension Table: Collection {
    var startIndex: Int { 0 }
    var endIndex: Int { count }
    func index(after i: Int) -> Int { i + 1 }

}

protocol TableRow {
    static var tokenKind: CLI.MetadataTokenKind { get }
    static func getSize(database: Database) -> Int
    static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self
}

struct TableRowRef<Row> where Row: TableRow {
    var table: Table<Row>
    var index: Int

    init(table: Table<Row>, index: Int) {
        precondition(index >= 0 && index < table.count)
        self.table = table
        self.index = index
    }

    var value: Row { table[index] }
}
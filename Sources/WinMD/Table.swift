class Table<Record> where Record: RecordProtocol {
    let buffer: UnsafeRawBufferPointer
    let database: Database
    let rowSize: Int

    init(buffer: UnsafeRawBufferPointer, database: Database) {
        self.buffer = buffer
        self.database = database
        self.rowSize = Record.getSize(database: database)
    }

    static var tokenKind: CLI.MetadataTokenKind { Record.tokenKind }
    var count: Int { buffer.count / rowSize }

    subscript(_ index: Int) -> Record {
        let rowBuffer = buffer.sub(offset: index * rowSize, count: rowSize)
        return Record.read(buffer: rowBuffer, database: database)
    }
}

extension Table: Collection {
    var startIndex: Int { 0 }
    var endIndex: Int { count }
    func index(after i: Int) -> Int { i + 1 }

}

protocol RecordProtocol {
    static var tokenKind: CLI.MetadataTokenKind { get }
    static func getSize(database: Database) -> Int
    static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self
}

struct RecordRef<Record> where Record: RecordProtocol {
    var table: Table<Record>
    var index: Int

    init(table: Table<Record>, index: Int) {
        precondition(index >= 0 && index < table.count)
        self.table = table
        self.index = index
    }

    var value: Record { table[index] }
}
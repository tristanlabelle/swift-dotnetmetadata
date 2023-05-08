public class Table<Row> where Row: Record {
    let buffer: UnsafeRawBufferPointer
    let database: Database
    let rowSize: Int

    init(buffer: UnsafeRawBufferPointer, database: Database) {
        self.buffer = buffer
        self.database = database
        self.rowSize = Row.getSize(database: database)
    }

    static var index: TableIndex { Row.tableIndex }
    public var count: Int { buffer.count / rowSize }

    public subscript(_ index: Int) -> Row {
        let rowBuffer = buffer.sub(offset: index * rowSize, count: rowSize)
        return Row.read(buffer: rowBuffer, database: database)
    }
}

extension Table: Collection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    public func index(after i: Int) -> Int { i + 1 }
}

public protocol Record {
    static var tableIndex: TableIndex { get }
    static func getSize(database: Database) -> Int
    static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self
}

public struct TableRowRef<Row> where Row: Record {
    var table: Table<Row>
    var index: Int

    init?(table: Table<Row>, index: Int) {
        precondition(index >= 0 && index < table.count)
        guard index != 0 else { return nil }
        self.table = table
        self.index = index
    }

    var value: Row { table[index] }
}
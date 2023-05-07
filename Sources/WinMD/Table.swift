public class Table<Record> where Record: RecordProtocol {
    let buffer: UnsafeRawBufferPointer
    let database: Database
    let rowSize: Int

    init(buffer: UnsafeRawBufferPointer, database: Database) {
        self.buffer = buffer
        self.database = database
        self.rowSize = Record.getSize(database: database)
    }

    static var tokenKind: MetadataTokenKind { Record.tokenKind }
    public var count: Int { buffer.count / rowSize }

    public subscript(_ index: Int) -> Record {
        let rowBuffer = buffer.sub(offset: index * rowSize, count: rowSize)
        return Record.read(buffer: rowBuffer, database: database)
    }
}

extension Table: Collection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    public func index(after i: Int) -> Int { i + 1 }

}

public protocol RecordProtocol {
    static var tokenKind: MetadataTokenKind { get }
    static func getSize(database: Database) -> Int
    static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self
}

public struct RecordRef<Record> where Record: RecordProtocol {
    var table: Table<Record>
    var index: Int

    init(table: Table<Record>, index: Int) {
        precondition(index >= 0 && index < table.count)
        self.table = table
        self.index = index
    }

    var value: Record { table[index] }
}
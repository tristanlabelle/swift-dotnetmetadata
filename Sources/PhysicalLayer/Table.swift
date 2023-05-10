public class Table<Row> where Row: TableRow {
    let buffer: UnsafeRawBufferPointer
    let dimensions: Database.Dimensions

    init(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        self.buffer = buffer
        self.dimensions = dimensions
    }

    static var index: TableIndex { Row.tableIndex }
    public var count: Int { dimensions.getRowCount(Row.tableIndex) }
    public var rowSize: Int { buffer.count / count }

    public subscript(_ index: Int) -> Row {
        let rowBuffer = buffer.sub(offset: index * rowSize, count: rowSize)
        return Row(reading: rowBuffer, dimensions: dimensions)
    }
}

extension Table: Collection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    public func index(after i: Int) -> Int { i + 1 }
}

public struct TableRowIndex<T> where T: TableRow {
    public var tableIndex: TableIndex { T.tableIndex }

    public var value: UInt32

    public init(_ index: UInt32) {
        precondition(index < 0x1_00_00_00)
        self.value = index
    }
}
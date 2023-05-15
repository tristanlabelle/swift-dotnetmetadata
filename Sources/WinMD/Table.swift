public final class Table<Row> where Row: TableRow {
    private let buffer: UnsafeRawBufferPointer
    private let sizes: TableSizes
    public let isSorted: Bool

    init(buffer: UnsafeRawBufferPointer, sizes: TableSizes, sorted: Bool) {
        self.buffer = buffer
        self.sizes = sizes
        self.isSorted = sorted
    }

    public static var index: TableIndex { Row.tableIndex }
    public var count: Int { sizes.getRowCount(Row.tableIndex) }
    public var rowSize: Int { buffer.count / count }

    /// Indexes into this table using zero-based indices
    public subscript(_ index: Int) -> Row {
        let rowBuffer = buffer.sub(offset: index * rowSize, count: rowSize)
        return Row(reading: rowBuffer, sizes: sizes)
    }

    public subscript(_ index: TableRowIndex<Row>) -> Row {
        self[index.zeroBased!]
    }
}

extension Table: RandomAccessCollection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    public func index(after i: Int) -> Int { i + 1 }
    public func index(before i: Int) -> Int { i - 1 }
    public func index(_ i: Int, offsetBy offset: Int) -> Int { i + offset }
}

extension Table where Row: KeyedTableRow {
    public func lookup(key: Row.PrimaryKey) -> TableRowIndex<Row> {
        precondition(isSorted)
        let index = self.binarySearch { $0.primaryKey < key }
        return index == count ? .null : .init(zeroBased: index)
    }
}
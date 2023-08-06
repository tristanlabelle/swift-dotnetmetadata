public final class Table<Row> where Row: TableRow {
    public typealias Row = Row

    private let buffer: UnsafeRawBufferPointer
    private let sizes: TableSizes
    public let isSorted: Bool

    init(buffer: UnsafeRawBufferPointer, sizes: TableSizes, sorted: Bool) {
        self.buffer = buffer
        self.sizes = sizes
        self.isSorted = sorted
    }

    public static var id: TableID { Row.tableID }
    public var count: Int { sizes.getRowCount(Row.tableID) }
    public var rowSize: Int { buffer.count / count }

    public subscript(zeroBasedIndex: Int) -> Row {
        let rowBuffer = buffer.sub(offset: zeroBasedIndex * rowSize, count: rowSize)
        return Row(reading: rowBuffer, sizes: sizes)
    }
}
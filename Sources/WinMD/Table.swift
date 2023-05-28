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

    public subscript(_ index: TableRowIndex<Row>) -> Row {
        self[Int(index.zeroBased)]
    }

    public subscript(zeroBasedIndex: Int) -> Row {
        let rowBuffer = buffer.sub(offset: zeroBasedIndex * rowSize, count: rowSize)
        return Row(reading: rowBuffer, sizes: sizes)
    }
}

extension Table: RandomAccessCollection {
    public typealias Element = Row
    public typealias Index = TableRowIndex<Row>

    public var startIndex: TableRowIndex<Row> { .init(zeroBased: 0) }
    public var endIndex: TableRowIndex<Row> { .init(zeroBased: UInt32(count)) }
    
    public func index(after i: TableRowIndex<Row>) -> TableRowIndex<Row> {
        .init(zeroBased: i.zeroBased + 1)
    }
    
    public func index(before i: TableRowIndex<Row>) -> TableRowIndex<Row> {
        .init(zeroBased: i.zeroBased - 1)
    }
    
    public func index(_ i: TableRowIndex<Row>, offsetBy offset: Int) -> TableRowIndex<Row> {
        .init(zeroBased: UInt32(Int(i.zeroBased) + offset))
    }
}

extension Table where Row: KeyedTableRow {
    public func find(primaryKey: Row.PrimaryKey) -> TableRowIndex<Row>? {
        precondition(isSorted)
        let insertIndex = self.binarySearchIndex { $0.primaryKey < primaryKey }
        guard insertIndex != startIndex else { return nil }

        let index = self.index(before: insertIndex)
        let row = self[index]
        return row.primaryKey == primaryKey ? index : nil
    }
}

extension Table where Row: DoublyKeyedTableRow {
    public func find(primaryKey: Row.PrimaryKey, secondaryKey: Row.SecondaryKey) -> TableRowIndex<Row>? {
        precondition(isSorted)
        let insertIndex = self.binarySearchIndex {
            if $0.primaryKey < primaryKey { return true }
            if $0.primaryKey > primaryKey { return false }
            return $0.secondaryKey < secondaryKey
        }

        let index = self.index(before: insertIndex)
        let row = self[index]
        return row.primaryKey == primaryKey && row.secondaryKey == secondaryKey ? index : nil
    }
}
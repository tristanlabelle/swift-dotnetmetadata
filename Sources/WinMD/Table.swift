public class Table<Row> where Row: TableRow {
    let buffer: UnsafeRawBufferPointer
    let dimensions: Database.Dimensions

    init(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        self.buffer = buffer
        self.dimensions = dimensions
    }

    public static var index: TableIndex { Row.tableIndex }
    public var count: Int { dimensions.getRowCount(Row.tableIndex) }
    public var rowSize: Int { buffer.count / count }

    /// Indexes into this table using zero-based indices
    public subscript(_ index: Int) -> Row {
        let rowBuffer = buffer.sub(offset: index * rowSize, count: rowSize)
        return Row(reading: rowBuffer, dimensions: dimensions)
    }

    public subscript(_ index: TableRowIndex<Row>) -> Row {
        self[index.zeroBased!]
    }
}

extension Table: Collection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    public func index(after i: Int) -> Int { i + 1 }
}

public struct TableRowIndex<T>: Comparable where T: TableRow {
    public static var tableIndex: TableIndex { T.tableIndex }
    public static var null: Self { .init(oneBased: 0) }

    public var oneBased: UInt32

    public init(oneBased: UInt32) {
        precondition(oneBased < 0x1_00_00_00)
        self.oneBased = oneBased
    }

    public init(zeroBased: Int) {
        precondition(zeroBased < 0xFF_FF_FF)
        self.init(oneBased: UInt32(zeroBased + 1))
    }

    public init(zeroBased: Int?) {
        self.init(oneBased: UInt32((zeroBased ?? -1) + 1))
    }

    public var isNull: Bool { oneBased == 0 }
    public var zeroBased: Int? { oneBased > 0 ? Int(oneBased - 1) : nil }

    public static func < (lhs: TableRowIndex, rhs: TableRowIndex) -> Bool {
        // 0, the null row, is considered last
        if (lhs.isNull) { return false }
        if (rhs.isNull) { return true }
        return lhs.oneBased < rhs.oneBased
    }
}
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

    public subscript(zeroBasedIndex: Int) -> Row {
        let rowBuffer = buffer.sub(offset: zeroBasedIndex * rowSize, count: rowSize)
        return Row(reading: rowBuffer, sizes: sizes)
    }
}

extension Table {
    /// A strongly-typed, 3-byte index of a metadata table row.
    /// In CLI (§II.22), they are one-based where zero means a null row:
    /// > Indexes to tables begin at 1, so index 1 means the first row in any given metadata table.
    /// > (An index value of zero denotes that it does not index a row at all;
    /// > that is, it behaves like a null reference.)
    /// To leverage the Swift type system better, we represent them as zero-based
    /// and use Optional<TableRowIndex> to represent nullability.
    public struct RowIndex: Hashable, Comparable {
        // Imitate a UInt24 using 3 bytes since values never exceed 0xFF_FF_FF and so Optional<TableRowIndex> is 4 bytes.
        private let low16: UInt16
        private let high8: UInt8

        public var zeroBased: UInt32 { (UInt32(high8) << 16) | UInt32(low16) }
        public var oneBased: UInt32 { zeroBased + 1 }

        public init(zeroBased: UInt32) {
            precondition(zeroBased < 0xFF_FF_FF)
            self.low16 = UInt16(zeroBased & 0xFF_FF)
            self.high8 = UInt8((zeroBased >> 16) & 0xFF)
        }

        public init?(oneBased: UInt32) {
            precondition(oneBased < 0x1_00_00_00)
            guard oneBased != 0 else { return nil }
            self.init(zeroBased: oneBased - 1)
        }

        public static func < (lhs: RowIndex, rhs: RowIndex) -> Bool {
            return lhs.zeroBased < rhs.zeroBased
        }
    }

    public subscript(_ index: Table<Row>.RowIndex) -> Row {
        self[Int(index.zeroBased)]
    }
}

extension Table.RowIndex: Strideable {
    public typealias Stride = Int

    public func distance(to other: Self) -> Stride {
        Int(other.zeroBased) - Int(zeroBased)
    }

    public func advanced(by n: Stride) -> Self {
        .init(zeroBased: UInt32(Int(zeroBased) + n))
    }
}

extension Table: RandomAccessCollection {
    public typealias Element = Row
    public typealias Index = Table<Row>.RowIndex

    public var startIndex: Table<Row>.RowIndex { .init(zeroBased: 0) }
    public var endIndex: Table<Row>.RowIndex { .init(zeroBased: UInt32(count)) }
    
    public func index(after i: Table<Row>.RowIndex) -> Table<Row>.RowIndex {
        .init(zeroBased: i.zeroBased + 1)
    }
    
    public func index(before i: Table<Row>.RowIndex) -> Table<Row>.RowIndex {
        .init(zeroBased: i.zeroBased - 1)
    }
    
    public func index(_ i: Table<Row>.RowIndex, offsetBy offset: Int) -> Table<Row>.RowIndex {
        .init(zeroBased: UInt32(Int(i.zeroBased) + offset))
    }
}

extension Table where Row: KeyedTableRow {
    public func find(primaryKey: Row.PrimaryKey) -> Table<Row>.RowIndex? {
        let index = self.binarySearchIndex { $0.primaryKey < primaryKey }
        guard index != startIndex && index != endIndex else { return nil }

        let row = self[index]
        return row.primaryKey == primaryKey ? index : nil
    }
}

extension Table where Row: DoublyKeyedTableRow {
    public func find(primaryKey: Row.PrimaryKey, secondaryKey: Row.SecondaryKey) -> Table<Row>.RowIndex? {
        let index = self.binarySearchIndex {
            $0.primaryKey != primaryKey ? $0.primaryKey < primaryKey : $0.secondaryKey < secondaryKey
        }
        guard index != startIndex && index != endIndex else { return nil }

        let row = self[index]
        return row.primaryKey == primaryKey && row.secondaryKey == secondaryKey ? index : nil
    }
}
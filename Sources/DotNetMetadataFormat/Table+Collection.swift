extension Table: RandomAccessCollection {
    public typealias RowRef = TableRowRef<Row>
    public typealias Element = Row
    public typealias Index = TableRowIndex

    public var startIndex: TableRowIndex { .init(zeroBased: 0) }
    public var endIndex: TableRowIndex { .init(zeroBased: UInt32(count)) }

    public func index(after i: TableRowIndex) -> TableRowIndex {
        .init(zeroBased: i.zeroBased + 1)
    }

    public func index(before i: TableRowIndex) -> TableRowIndex {
        .init(zeroBased: i.zeroBased - 1)
    }

    public func index(_ i: TableRowIndex, offsetBy offset: Int) -> TableRowIndex {
        .init(zeroBased: UInt32(Int(i.zeroBased) + offset))
    }
}
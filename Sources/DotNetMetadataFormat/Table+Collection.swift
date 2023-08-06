extension Table: RandomAccessCollection {
    public typealias RowIndex = TableRowIndex<Row>
    public typealias Element = Row
    public typealias Index = RowIndex

    public var startIndex: RowIndex { .init(zeroBased: 0) }
    public var endIndex: RowIndex { .init(zeroBased: UInt32(count)) }

    public subscript(_ index: RowIndex) -> Row {
        self[Int(index.zeroBased)]
    }

    public func index(after i: RowIndex) -> RowIndex {
        .init(zeroBased: i.zeroBased + 1)
    }
    
    public func index(before i: RowIndex) -> RowIndex {
        .init(zeroBased: i.zeroBased - 1)
    }
    
    public func index(_ i: RowIndex, offsetBy offset: Int) -> RowIndex {
        .init(zeroBased: UInt32(Int(i.zeroBased) + offset))
    }
}
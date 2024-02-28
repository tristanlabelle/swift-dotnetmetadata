/// Computes the size of a table row by adding the size of its column values.
internal struct TableRowSizeBuilder<Row> where Row: TableRow {
    let sizes: TableSizes
    let size: Int

    init(sizes: TableSizes, size: Int = 0) {
        self.sizes = sizes
        self.size = size
    }

    private func adding(size: Int) -> Self {
        return Self(sizes: sizes, size: self.size + size)
    }

    public func addingConstant<T>(_: KeyPath<Row, T>) -> Self {
        adding(size: MemoryLayout<T>.stride)
    }

    public func addingHeapOffset<T: Heap>(_: KeyPath<Row, HeapOffset<T>>) -> Self {
        adding(size: sizes.getHeapOffsetSize(T.self))
    }

    public func addingTableRowRef<OtherRow: TableRow>(_: KeyPath<Row, TableRowRef<OtherRow>>) -> Self {
        adding(size: sizes.getTableRowIndexSize(OtherRow.tableID))
    }

    public func addingCodedIndex<Tag: CodedIndexTag>(_: KeyPath<Row, CodedIndex<Tag>>) -> Self {
        adding(size: sizes.getCodedIndexSize(Tag.self))
    }

    public func addingPaddingByte() -> Self {
        return adding(size: 1)
    }
}
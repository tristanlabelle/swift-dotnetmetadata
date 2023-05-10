/// Computes the size of a table row by adding the size of its column values.
struct TableRowSizer<Row> where Row: TableRow {
    let dimensions: Database.Dimensions
    let size: Int

    init(dimensions: Database.Dimensions, size: Int = 0) {
        self.dimensions = dimensions
        self.size = size
    }

    private func adding(size: Int) -> Self {
        return Self(dimensions: dimensions, size: self.size + size)
    }

    public func addingConstant<T>(_: KeyPath<Row, T>) -> Self {
        adding(size: MemoryLayout<T>.stride)
    }

    public func addingHeapEntry<T>(_: KeyPath<Row, HeapEntry<T>>) -> Self where T: Heap {
        adding(size: dimensions.getHeapEntrySize(T.self))
    }
    
    public func addingTableRowIndex<T>(_: KeyPath<Row, TableRowIndex<T>>) -> Self where T: TableRow {
        adding(size: dimensions.getTableRowSize(T.tableIndex))
    }
    
    public func addingCodedIndex<T>(_: KeyPath<Row, T>) -> Self where T: CodedIndex {
        adding(size: dimensions.getCodedIndexSize(T.self))
    }
}
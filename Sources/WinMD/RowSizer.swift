struct RowSizer<Row> where Row: Record {
    let dimensions: Database.Dimensions
    let size: Int

    init(dimensions: Database.Dimensions, size: Int = 0) {
        self.dimensions = dimensions
        self.size = size
    }

    private func add(size: Int) -> Self {
        return Self(dimensions: dimensions, size: self.size + size)
    }

    public func addConstant<T>(_: KeyPath<Row, T>) -> Self {
        add(size: MemoryLayout<T>.stride)
    }

    public func addHeapOffset<T>(_: KeyPath<Row, HeapOffset<T>>) -> Self where T: Heap {
        add(size: dimensions.getHeapOffsetSize(T.self))
    }
    
    public func addRowIndex<T>(_: KeyPath<Row, RowIndex<T>>) -> Self where T: Record {
        add(size: dimensions.getRowIndexSize(T.tableIndex))
    }
    
    public func addCodedIndex<T>(_: KeyPath<Row, T>) -> Self where T: CodedIndex {
        add(size: dimensions.getCodedIndexSize(T.self))
    }
}
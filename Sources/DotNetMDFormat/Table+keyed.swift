extension Table where Row: KeyedTableRow {
    public func findAny(primaryKey: Row.PrimaryKey) -> RowIndex? {
        binarySearch(for: primaryKey, selector: { $0.primaryKey }).asOptional
    }

    public func findFirst(primaryKey: Row.PrimaryKey) -> RowIndex? {
        binarySearch(for: primaryKey, selector: { $0.primaryKey }, matchPreference: .first).asOptional
    }

    public func findAll(primaryKey: Row.PrimaryKey) -> Range<RowIndex> {
        binarySearchRange(for: primaryKey, selector: { $0.primaryKey })
    }
}

extension Table where Row: DoublyKeyedTableRow {
    public func findAny(primaryKey: Row.PrimaryKey, secondaryKey: Row.SecondaryKey) -> RowIndex? {
        self.binarySearch(
            for: (primaryKey, secondaryKey),
            selector: { ($0.primaryKey, $0.secondaryKey) },
            lessThan: <).asOptional
    }

    public func findFirst(primaryKey: Row.PrimaryKey, secondaryKey: Row.SecondaryKey) -> RowIndex? {
        self.binarySearch(
            for: (primaryKey, secondaryKey),
            selector: { ($0.primaryKey, $0.secondaryKey) },
            lessThan: <,
            matchPreference: .first).asOptional
    }
}
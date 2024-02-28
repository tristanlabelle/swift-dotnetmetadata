extension Table where Row: KeyedTableRow {
    public func findAny(primaryKey: Row.PrimaryKey) -> TableRowIndex? {
        binarySearch(for: primaryKey, selector: { $0.primaryKey }).asOptional
    }

    public func findFirst(primaryKey: Row.PrimaryKey) -> TableRowIndex? {
        binarySearch(for: primaryKey, selector: { $0.primaryKey }, matchPreference: .first).asOptional
    }

    public func findAll(primaryKey: Row.PrimaryKey) -> Range<TableRowIndex> {
        binarySearchRange(for: primaryKey, selector: { $0.primaryKey })
    }
}

extension Table where Row: DoublyKeyedTableRow {
    public func findAny(primaryKey: Row.PrimaryKey, secondaryKey: Row.SecondaryKey) -> TableRowIndex? {
        self.binarySearch(
            for: (primaryKey, secondaryKey),
            selector: { ($0.primaryKey, $0.secondaryKey) },
            lessThan: <).asOptional
    }

    public func findFirst(primaryKey: Row.PrimaryKey, secondaryKey: Row.SecondaryKey) -> TableRowIndex? {
        self.binarySearch(
            for: (primaryKey, secondaryKey),
            selector: { ($0.primaryKey, $0.secondaryKey) },
            lessThan: <,
            matchPreference: .first).asOptional
    }
}

extension NestedClassTable {
    public func findAllNested(enclosing: TypeDefTable.RowRef) -> Range<TableRowIndex> {
        binarySearchRange(for: enclosing, selector: { $0.enclosingClass })
    }
}
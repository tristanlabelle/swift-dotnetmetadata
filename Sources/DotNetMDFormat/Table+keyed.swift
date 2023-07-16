extension Table where Row: KeyedTableRow {
    public func findAny(primaryKey: Row.PrimaryKey) -> RowIndex? {
        guard case let .present(at: index) = self.binarySearch(
            for: primaryKey,
            selector: { $0.primaryKey }) else { return nil }
        return index
    }

    public func findFirst(primaryKey: Row.PrimaryKey) -> RowIndex? {
        guard var firstIndex = findAny(primaryKey: primaryKey) else { return nil }
        while firstIndex != startIndex {
            let previousIndex = self.index(before: firstIndex)
            let previousRow = self[previousIndex]
            guard previousRow.primaryKey == primaryKey else { break }
            firstIndex = previousIndex
        }
        return firstIndex
    }
}

extension Table where Row: DoublyKeyedTableRow {
    public func findAny(primaryKey: Row.PrimaryKey, secondaryKey: Row.SecondaryKey) -> RowIndex? {
        guard case let .present(at: index) = self.binarySearch(
            for: (primaryKey, secondaryKey),
            selector: { ($0.primaryKey, $0.secondaryKey) },
            lessThan: <) else { return nil }
        return index
    }

    public func findFirst(primaryKey: Row.PrimaryKey, secondaryKey: Row.SecondaryKey) -> RowIndex? {
        guard var firstIndex = findAny(primaryKey: primaryKey, secondaryKey: secondaryKey) else { return nil }
        while firstIndex != startIndex {
            let previousIndex = self.index(before: firstIndex)
            let previousRow = self[previousIndex]
            guard previousRow.primaryKey == primaryKey && previousRow.secondaryKey == secondaryKey else { break }
            firstIndex = previousIndex
        }
        return firstIndex
    }
}
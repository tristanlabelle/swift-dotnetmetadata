import WinMD

func getChildRowRange<Parent, Child>(
    parent: Table<Parent>,
    parentRowIndex: TableRowIndex<Parent>,
    childTable: Table<Child>,
    childSelector: (Parent) -> TableRowIndex<Child>) -> Range<Int>
    where Parent : TableRow, Child: TableRow {
    let parentIndex = parentRowIndex.zeroBased!
    guard let firstChildIndex = childSelector(parent[parentIndex]).zeroBased else {
        return 0 ..< 0
    }

    if parentIndex + 1 == parent.count {
        return firstChildIndex ..< childTable.count
    }
    else {
        let endChildIndex = childSelector(parent[parentIndex + 1]).zeroBased!
        return firstChildIndex ..< endChildIndex
    }
}
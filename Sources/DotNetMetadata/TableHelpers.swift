import DotNetMetadataFormat

func getChildRowRange<Parent, Child>(
    parent: Table<Parent>,
    parentRowIndex: TableRowIndex,
    childTable: Table<Child>,
    childSelector: (Parent) -> Table<Child>.RowRef) -> Range<TableRowIndex>
    where Parent : TableRow, Child: TableRow {
    guard let firstChildIndex = childSelector(parent[parentRowIndex]).index else {
        return childTable.endIndex ..< childTable.endIndex
    }

    let nextParentRowIndex = parent.index(after: parentRowIndex)
    if nextParentRowIndex == parent.endIndex {
        return firstChildIndex ..< childTable.endIndex
    }
    else {
        let endChildIndex = childSelector(parent[nextParentRowIndex]).index!
        return firstChildIndex ..< endChildIndex
    }
}
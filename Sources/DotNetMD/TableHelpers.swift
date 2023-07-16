import DotNetMDFormat

func getChildRowRange<Parent, Child>(
    parent: Table<Parent>,
    parentRowIndex: TableRowIndex<Parent>,
    childTable: Table<Child>,
    childSelector: (Parent) -> TableRowIndex<Child>?) -> Range<TableRowIndex<Child>>
    where Parent : TableRow, Child: TableRow {
    guard let firstChildIndex = childSelector(parent[parentRowIndex]) else {
        return childTable.endIndex ..< childTable.endIndex
    }

    let nextParentRowIndex = parent.index(after: parentRowIndex)
    if nextParentRowIndex == parent.endIndex {
        return firstChildIndex ..< childTable.endIndex
    }
    else {
        let endChildIndex = childSelector(parent[nextParentRowIndex])!
        return firstChildIndex ..< endChildIndex
    }
}
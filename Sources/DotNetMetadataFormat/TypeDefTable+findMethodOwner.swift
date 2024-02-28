extension TypeDefTable {
    public func findMethodDefOwner(rowIndex methodDefRowIndex: TableRowIndex) -> TableRowIndex? {
        let result = self.binarySearch(for: .init(index: methodDefRowIndex), selector: { $0.methodList }, lessThan: { $0 < $1 })
        switch result {
            case .present(at: let foundIndex):
                var index = foundIndex
                while true {
                    let nextIndex = self.index(after: index)
                    if nextIndex == endIndex { break }
                    let nextRow: Row = self[nextIndex]
                    if nextRow.methodList.index != methodDefRowIndex { break }
                    index = nextIndex
                }
                return index

            case .absent(insertAt: let index):
                return index == startIndex ? nil : self.index(before: index)
        }
    }
}
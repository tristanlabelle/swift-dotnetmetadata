extension TypeDefTable {
    public func findMethodOwner(_ method: MethodDefTable.RowIndex) -> TypeDefTable.RowIndex? {
        let result = self.binarySearch(for: method, selector: { $0.methodList! }, lessThan: { $0 < $1 })
        switch result {
            case .present(at: let foundIndex):
                var index = foundIndex
                while true {
                    let nextIndex = self.index(after: index)
                    if nextIndex != endIndex && self[nextIndex].methodList == method {
                        index = nextIndex
                        continue
                    }

                    return index
                }

            case .absent(insertAt: let index):
                return index == startIndex ? nil : self.index(before: index)
        }
    }
}
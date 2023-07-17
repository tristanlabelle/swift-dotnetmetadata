extension RandomAccessCollection {
    func binarySearch<Key>(for key: Key, selector: (Element) -> Key, lessThan: (Key, Key) -> Bool) -> BinarySearchResult<Index> {
        guard !isEmpty else { return .absent(insertAt: startIndex) }

        var lowIndex = startIndex
        var highIndex = endIndex
        while true {
            let midIndex = index(lowIndex, offsetBy: distance(from: lowIndex, to: highIndex) / 2)
            let midKey = selector(self[midIndex])
            if lessThan(key, midKey) { // key < midKey
                highIndex = midIndex
                guard lowIndex != highIndex else { return .absent(insertAt: lowIndex) }
            }
            else if lessThan(midKey, key) { // key > midKey
                lowIndex = index(after: midIndex)
                guard lowIndex != endIndex else { return .absent(insertAt: endIndex) }
            }
            else {
                return .present(at: midIndex)
            }
        }
    }

    func binarySearch<Key: Comparable>(for key: Key, selector: (Element) -> Key) -> BinarySearchResult<Index> {
        binarySearch(for: key, selector: selector, lessThan: <)
    }
}

extension RandomAccessCollection where Element: Comparable {
    func binarySearch(for key: Element) -> BinarySearchResult<Index> {
        binarySearch(for: key, selector: { $0 })
    }
}

enum BinarySearchResult<Index> {
    case present(at: Index)
    case absent(insertAt: Index)
}

extension BinarySearchResult: Equatable where Index: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.present(at: let lhs), .present(at: let rhs)): return lhs == rhs
            case (.absent(insertAt: let lhs), .absent(insertAt: let rhs)): return lhs == rhs
            default: return false
        }
    }
}
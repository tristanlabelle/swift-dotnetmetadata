extension RandomAccessCollection {
    func binarySearch<Key>(for key: Key, selector: (Element) -> Key, lessThan: (Key, Key) -> Bool) -> BinarySearchResult<Index> {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            if lessThan(selector(self[mid]), key) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }

        return low != endIndex && !lessThan(key, selector(self[low]))
            ? .present(at: low)
            : .absent(insertAt: low)
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
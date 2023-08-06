extension RandomAccessCollection {
    func binarySearch<Key>(
        for key: Key, selector: (Element) -> Key, lessThan: (Key, Key) -> Bool,
        matchPreference: BinarySearchMatchPreference = .any) -> BinarySearchResult<Index> {

        guard !isEmpty else { return .absent(insertAt: startIndex) }

        var lowIndex = startIndex
        var highIndex = endIndex
        var matchIndex: Index? = nil
        while true {
            let midIndex = index(lowIndex, offsetBy: distance(from: lowIndex, to: highIndex) / 2)
            let midKey = selector(self[midIndex])
            if lessThan(key, midKey) { // key < midKey
                highIndex = midIndex
                if lowIndex == highIndex { break }
            }
            else if lessThan(midKey, key) { // key > midKey
                lowIndex = index(after: midIndex)
                if lowIndex == endIndex { break }
            }
            else {
                switch matchPreference {
                    case .first:
                        highIndex = midIndex
                        if lowIndex == highIndex { return .present(at: midIndex) }

                    case .any: return .present(at: midIndex)

                    case .last:
                        lowIndex = index(after: midIndex)
                        if lowIndex == endIndex { return .present(at: midIndex) }
                }

                matchIndex = midIndex
            }
        }

        if let matchIndex { return .present(at: matchIndex) }
        return .absent(insertAt: lowIndex)
    }

    func binarySearch<Key: Comparable>(for key: Key, selector: (Element) -> Key,
        matchPreference: BinarySearchMatchPreference = .any) -> BinarySearchResult<Index> {
        binarySearch(for: key, selector: selector, lessThan: <, matchPreference: matchPreference)
    }

    func binarySearchRange<Key>(for key: Key, selector: (Element) -> Key, lessThan: (Key, Key) -> Bool) -> Range<Index> {
        switch binarySearch(for: key, selector: selector, lessThan: lessThan, matchPreference: .first) {
            case .present(at: let firstIndex):
                // Optimize for the single match case
                let nextIndex = index(after: firstIndex)
                if nextIndex == endIndex || lessThan(key, selector(self[nextIndex])) {
                    return firstIndex..<nextIndex
                }

                let lastIndex =  binarySearch(for: key, selector: selector, lessThan: lessThan, matchPreference: .last).asOptional!
                return firstIndex..<index(after: lastIndex)

            case .absent(insertAt: let index):
                return index..<index
        }
    }

    func binarySearchRange<Key: Comparable>(for key: Key, selector: (Element) -> Key) -> Range<Index> {
        binarySearchRange(for: key, selector: selector, lessThan: <)
    }
}

extension RandomAccessCollection where Element: Comparable {
    func binarySearch(for key: Element, matchPreference: BinarySearchMatchPreference = .any) -> BinarySearchResult<Index> {
        binarySearch(for: key, selector: { $0 }, matchPreference: matchPreference)
    }

    func binarySearchRange(for key: Element) -> Range<Index> {
        binarySearchRange(for: key, selector: { $0 })
    }
}

enum BinarySearchMatchPreference: Hashable {
    case first
    case any
    case last
}

enum BinarySearchResult<Index> {
    case present(at: Index)
    case absent(insertAt: Index)
}

extension BinarySearchResult {
    var asOptional: Index? {
        switch self {
            case .present(at: let index): return index
            case .absent(insertAt: _): return nil
        }
    }
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
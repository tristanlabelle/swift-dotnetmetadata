extension TableRowIndex {
    public struct SortingKey: Comparable {
        public let oneBasedIndex: UInt32

        public init(index: TableRowIndex<Row>?) {
            self.oneBasedIndex = index?.oneBased ?? 0
        }

        public static func < (lhs: SortingKey, rhs: SortingKey) -> Bool {
            lhs.oneBasedIndex < rhs.oneBasedIndex
        }
    }
}

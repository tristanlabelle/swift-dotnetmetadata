/// A reference to a metadata table row, which might be null.
/// This is a wrapper for an Optional<TableRowIndex> that encodes table information,
/// and which can be used as a sorting key for table lookups.
public struct TableRowRef<Row: TableRow>: Hashable, Comparable {
    public static var null: TableRowRef<Row> { .init() }

    public let oneBasedIndex: UInt32

    private init() {
        self.oneBasedIndex = 0
    }

    public init(index: TableRowIndex?) {
        self.init(oneBasedIndex: index.oneBased)
    }

    public init(index: TableRowIndex) {
        self.init(oneBasedIndex: index.oneBased)
    }

    public init(oneBasedIndex: UInt32) {
        precondition(oneBasedIndex < 0x1_00_00_00)
        self.oneBasedIndex = oneBasedIndex
    }

    public var isNull: Bool { oneBasedIndex == 0 }
    public var index: TableRowIndex? { .init(oneBased: oneBasedIndex) }
    public var zeroBasedIndex: UInt32? { index?.zeroBased }
    public var metadataToken: MetadataToken { .init(self) }

    public static func < (lhs: TableRowRef<Row>, rhs: TableRowRef<Row>) -> Bool {
        lhs.oneBasedIndex < rhs.oneBasedIndex
    }
}


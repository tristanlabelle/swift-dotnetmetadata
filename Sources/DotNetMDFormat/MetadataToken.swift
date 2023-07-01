public struct MetadataToken: Hashable, Comparable {
    // When indexing into a table, the table index should be the least significant byte of the token.
    public typealias TableKey = UInt32

    public var rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public init(tableIndex: TableIndex, oneBasedRowIndex: UInt32) {
        precondition(oneBasedRowIndex < 0x1000000)
        rawValue = (UInt32(tableIndex.rawValue) << 24) | oneBasedRowIndex
    }

    public init(nullOf tableIndex: TableIndex) {
        rawValue = UInt32(tableIndex.rawValue) << 24
    }
    
    public init<Row: TableRow>(_ rowIndex: Table<Row>.RowIndex) {
        self.init(tableIndex: Row.tableIndex, oneBasedRowIndex: rowIndex.oneBased)
    }

    public init<Row: TableRow>(_ rowIndex: Table<Row>.RowIndex?) {
        self.init(tableIndex: Row.tableIndex, oneBasedRowIndex: rowIndex?.oneBased ?? 0)
    }

    public init<Index: CodedIndex>(_ codedIndex: Index) {
        self = codedIndex.metadataToken
    }

    public var tableKey: TableKey { (rawValue >> 24) | (rawValue << 8) }
    // TODO: This is not necessarily a table index. Other tokens are possible: string = 0x70, name = 0x71, baseType = 0x72
    public var tableIndex: TableIndex { .init(rawValue: UInt8(rawValue >> 24))! }
    public var oneBasedRowIndex: UInt32 { rawValue & 0xFFFFFF }
    public var isNull: Bool { oneBasedRowIndex == 0 }

    public static func < (lhs: MetadataToken, rhs: MetadataToken) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
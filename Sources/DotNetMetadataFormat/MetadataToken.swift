public struct MetadataToken: Hashable, Comparable {
    public var rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public init(tableID: TableID, oneBasedRowIndex: UInt32) {
        precondition(oneBasedRowIndex < 0x1000000)
        rawValue = (UInt32(tableID.rawValue) << 24) | oneBasedRowIndex
    }

    public init(tableID: TableID, rowIndex: TableRowIndex?) {
        self.init(tableID: tableID, oneBasedRowIndex: rowIndex?.oneBased ?? 0)
    }

    public init(nullOf tableID: TableID) {
        rawValue = UInt32(tableID.rawValue) << 24
    }

    public init<Row: TableRow>(_ tableRowRef: TableRowRef<Row>) {
        self.init(tableID: Row.tableID, rowIndex: tableRowRef.index)
    }

    // TODO: This is not necessarily a table index. Other tokens are possible: string = 0x70, name = 0x71, baseType = 0x72
    public var tableID: TableID { .init(rawValue: UInt8(rawValue >> 24))! }
    public var oneBasedRowIndex: UInt32 { rawValue & 0xFFFFFF }
    public var rowIndex: TableRowIndex? { .init(oneBased: oneBasedRowIndex) }
    public var isNull: Bool { rowIndex == nil }

    public static func < (lhs: MetadataToken, rhs: MetadataToken) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
/// Holds size information about metadata tables,
/// allowing for computing column sizes.
public final class TableSizes {
    public let tableRowCounts: [UInt32]
    public let heapSizingBits: UInt8

    public init(heapSizingBits: UInt8, tableRowCounts: [UInt32]) {
        precondition(tableRowCounts.count == TableID.count)
        self.heapSizingBits = heapSizingBits
        self.tableRowCounts = tableRowCounts
    }

    public var stringHeapOffsetSize: Int { (heapSizingBits & 1) == 0 ? 2 : 4 }
    public var guidHeapOffsetSize: Int { (heapSizingBits & 2) == 0 ? 2 : 4 }
    public var blobHeapOffsetSize: Int { (heapSizingBits & 4) == 0 ? 2 : 4 }

    public func getRowCount(_ tableID: Int) -> Int {
        Int(tableRowCounts[tableID])
    }

    public func getRowCount(_ tableID: TableID) -> Int {
        Int(tableRowCounts[Int(tableID.rawValue)])
    }
    
    public func getRowCount<Row>(_: Row.Type) -> Int where Row: TableRow {
        getRowCount(Row.tableID)
    }

    public func getHeapOffsetSize<T>(_: T.Type) -> Int where T: Heap {
        if T.self == StringHeap.self { return stringHeapOffsetSize }
        if T.self == GuidHeap.self { return guidHeapOffsetSize }
        if T.self == BlobHeap.self { return blobHeapOffsetSize }
        fatalError("Unexpeted heap type \(T.self)")
    }

    public func getTableRowIndexSize(_ tableID: TableID) -> Int {
        // §II.24.2.6:
        // > If e is a simple index into a table with index i,
        // > it is stored using 2 bytes if table i has less than 2^16 rows,
        // > otherwise it is stored using 4 bytes.
        getRowCount(tableID) < 0x10000 ? 2 : 4
    }
    
    public func getTableRowIndexSize<Row>(_: Row.Type) -> Int where Row: TableRow {
        getTableRowIndexSize(Row.tableID)
    }

    public func getCodedIndexSize<Tag>(_: Tag.Type) -> Int where Tag: CodedIndexTag {
        // The most significant bits are reserved for the tag,
        // depending on how many different tables this can index into.
        // The rest of the bits are the row index.
        // The coded index is 32 bits iff at least one indexed table
        // has more rows than could be indexed using the row index bits
        // if the coded index was 16 bits.
        let maxRowCount = Tag.tables.compactMap { $0 }.map { tableRowCounts[Int($0.rawValue)] }.max()!
        return maxRowCount < (1 << (16 - Tag.bitCount)) ? 2 : 4
    }
}
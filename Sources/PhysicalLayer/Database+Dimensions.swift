extension Database {
    public class Dimensions {
        public let tableRowCounts: [UInt32]
        public let heapSizes: UInt8

        public init(heapSizes: UInt8, tableRowCounts: [UInt32]) {
            precondition(tableRowCounts.count == 64)
            self.heapSizes = heapSizes
            self.tableRowCounts = tableRowCounts
        }

        public var stringHeapOffsetSize: Int { (heapSizes & 1) == 0 ? 2 : 4 }
        public var guidHeapOffsetSize: Int { (heapSizes & 2) == 0 ? 2 : 4 }
        public var blobHeapOffsetSize: Int { (heapSizes & 4) == 0 ? 2 : 4 }

        public func getRowCount(_ tableIndex: TableIndex) -> Int {
            Int(tableRowCounts[Int(tableIndex.rawValue)])
        }
        
        public func getRowCount<Row>(_: Row.Type) -> Int where Row: TableRow {
            getRowCount(Row.tableIndex)
        }

        public func getHeapOffsetSize<T>(_: T.Type) -> Int where T: Heap {
            if T.self == StringHeap.self { return stringHeapOffsetSize }
            if T.self == GuidHeap.self { return guidHeapOffsetSize }
            if T.self == BlobHeap.self { return blobHeapOffsetSize }
            fatalError("Unexpeted heap type \(T.self)")
        }

        public func getTableRowSize(_ tableIndex: TableIndex) -> Int {
            getRowCount(tableIndex) < 0x1000 ? 2 : 4
        }
        
        public func getTableRowSize<Row>(_: Row.Type) -> Int where Row: TableRow {
            getTableRowSize(Row.tableIndex)
        }

        public func getCodedIndexSize<T>(_: T.Type) -> Int where T: CodedIndex {
            let tagBitCount = Int.bitWidth - T.tables.count.leadingZeroBitCount
            let maxRowCount = T.tables.compactMap { $0 }.map { tableRowCounts[Int($0.rawValue)] }.max()!
            return maxRowCount < (1 << (16 - tagBitCount)) ? 2 : 4
        }
    }
}
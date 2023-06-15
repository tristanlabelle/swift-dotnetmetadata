/// Reads a table row one column value at a time.
struct TableRowReader {
    private var remainder: UnsafeRawBufferPointer
    private let sizes: TableSizes

    init(buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self.remainder = buffer
        self.sizes = sizes
    }

    mutating func readConstant<T>(last: Bool = false) -> T {
        let result = remainder.consume(type: T.self).pointee
        if last { checkAtEnd() }
        return result
    }

    mutating func readHeapOffset<T>(last: Bool = false) -> HeapOffset<T> where T: Heap {
        let index = sizes.getHeapOffsetSize(T.self) == 2
            ? UInt32(remainder.consume(type: UInt16.self).pointee)
            : remainder.consume(type: UInt32.self).pointee
        if last { checkAtEnd() }
        return .init(index)
    }

    mutating func readTableRowIndex<T>(last: Bool = false) -> Table<T>.RowIndex? where T: TableRow {
        let oneBasedIndex = sizes.getTableRowIndexSize(T.self) == 2
            ? UInt32(remainder.consume(type: UInt16.self).pointee)
            : remainder.consume(type: UInt32.self).pointee
        if last { checkAtEnd() }
        return .init(oneBased: oneBasedIndex)
    }

    mutating func readCodedIndex<Index>(last: Bool = false) -> Index where Index: CodedIndex {
        let codedValue: UInt32
        if sizes.getCodedIndexSize(Index.self) == 2 {
            codedValue = UInt32(remainder.consume(type: UInt16.self).pointee)
        }
        else {
            codedValue = remainder.consume(type: UInt32.self).pointee
        }

        // §II.24.2.6: "The actual table is encoded into the low [N] bits of the number"
        let tag = UInt8(codedValue & ((1 << Index.tagBitCount) - 1))
        let index = codedValue >> Index.tagBitCount
        let result = Index(tag: tag, oneBasedIndex: index)
        if last { checkAtEnd() }
        return result
    }

    func checkAtEnd() {
        if remainder.count > 0 {
            fatalError()
        }
    }
}
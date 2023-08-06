/// Reads a table row one column value at a time.
struct TableRowReader {
    private var remainder: UnsafeRawBufferPointer
    private let sizes: TableSizes

    private init(buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self.remainder = buffer
        self.sizes = sizes
    }

    public static func read<Row: TableRow>(buffer: UnsafeRawBufferPointer, sizes: TableSizes, callback: (inout TableRowReader) -> Row) -> Row {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        let result = callback(&reader)
        if !reader.remainder.isEmpty { fatalError() }
        return result
    }

    mutating func readConstant<T>() -> T {
        return remainder.consume(type: T.self).pointee
    }

    mutating func readHeapOffset<T: Heap>() -> HeapOffset<T> {
        return .init(
            sizes.getHeapOffsetSize(T.self) == 2
                ? UInt32(remainder.consume(type: UInt16.self).pointee)
                : remainder.consume(type: UInt32.self).pointee)
    }

    mutating func readTableRowIndex<T: TableRow>() -> TableRowIndex<T>? {
        return .init(
            oneBased: sizes.getTableRowIndexSize(T.self) == 2
                ? UInt32(remainder.consume(type: UInt16.self).pointee)
                : remainder.consume(type: UInt32.self).pointee)
    }

    mutating func readCodedIndex<Index: CodedIndex>() -> Index {
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
        return result
    }
}
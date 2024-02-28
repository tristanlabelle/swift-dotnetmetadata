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

    mutating func readTableRowRef<OtherRow: TableRow>() -> TableRowRef<OtherRow> {
        return .init(
            oneBasedIndex: sizes.getTableRowIndexSize(OtherRow.self) == 2
                ? UInt32(remainder.consume(type: UInt16.self).pointee)
                : remainder.consume(type: UInt32.self).pointee)
    }

    mutating func readCodedIndex<Tag: CodedIndexTag>() -> CodedIndex<Tag> {
        CodedIndex<Tag>(value: sizes.getCodedIndexSize(Tag.self) == 2
            ? UInt32(remainder.consume(type: UInt16.self).pointee)
            : remainder.consume(type: UInt32.self).pointee)
    }
}
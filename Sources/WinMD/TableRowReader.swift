/// Reads a table row one column value at a time.
struct TableRowReader {
    var remainder: UnsafeRawBufferPointer
    let dimensions: Database.Dimensions

    init(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        self.remainder = buffer
        self.dimensions = dimensions
    }

    mutating func readConstant<T>(last: Bool = false) -> T {
        let result = remainder.consume(type: T.self).pointee
        if last { checkAtEnd() }
        return result
    }

    mutating func readHeapOffset<T>(last: Bool = false) -> HeapOffset<T> where T: Heap {
        let index = dimensions.getHeapOffsetSize(T.self) == 2
            ? UInt32(remainder.consume(type: UInt16.self).pointee)
            : remainder.consume(type: UInt32.self).pointee
        if last { checkAtEnd() }
        return HeapOffset<T>(index)
    }

    mutating func readTableRowIndex<T>(last: Bool = false) -> TableRowIndex<T> where T: TableRow {
        let index = dimensions.getTableRowSize(T.self) == 2
            ? UInt32(remainder.consume(type: UInt16.self).pointee)
            : remainder.consume(type: UInt32.self).pointee
        if last { checkAtEnd() }
        return TableRowIndex<T>(index)
    }

    mutating func readCodedIndex<T>(last: Bool = false) -> T where T: CodedIndex {
        let tagBitCount = Int.bitWidth - T.tables.count.leadingZeroBitCount

        let codedValue: UInt32
        let indexBitCount: Int
        if dimensions.getCodedIndexSize(T.self) == 2 {
            codedValue = UInt32(remainder.consume(type: UInt16.self).pointee)
            indexBitCount = 16 - tagBitCount
        }
        else {
            codedValue = remainder.consume(type: UInt32.self).pointee
            indexBitCount = 32 - tagBitCount
        }

        let tag = UInt8(codedValue >> indexBitCount)
        let index = codedValue & ((1 << indexBitCount) - 1)
        let result = T(tag: tag, index: index)
        if last { checkAtEnd() }
        return result
    }

    func checkAtEnd() {
        if remainder.count > 0 {
            fatalError()
        }
    }
}
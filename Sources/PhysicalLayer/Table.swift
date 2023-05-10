public class Table<Row> where Row: Record {
    let buffer: UnsafeRawBufferPointer
    let dimensions: Database.Dimensions

    init(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        self.buffer = buffer
        self.dimensions = dimensions
    }

    static var index: TableIndex { Row.tableIndex }
    public var count: Int { dimensions.getRowCount(Row.tableIndex) }
    public var rowSize: Int { buffer.count / count }

    public subscript(_ index: Int) -> Row {
        let rowBuffer = buffer.sub(offset: index * rowSize, count: rowSize)
        return Row.read(buffer: rowBuffer, dimensions: dimensions)
    }
}

extension Table: Collection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    public func index(after i: Int) -> Int { i + 1 }
}

public protocol Record {
    static var tableIndex: TableIndex { get }
    static func getSize(dimensions: Database.Dimensions) -> Int
    static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self
}

public struct TableRow<T> where T: Record {
    public var tableIndex: TableIndex { T.tableIndex }

    public var index: UInt32

    public init(_ index: UInt32) {
        precondition(index >= 0)
        self.index = index
    }
}
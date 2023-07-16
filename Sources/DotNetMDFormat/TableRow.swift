/// A row in a metadata table
/// The size of rows isn't constant because the size of columns which index
/// into heaps or other metadata tables depends on the size of these heaps/tables.
public protocol TableRow {
    static var tableIndex: TableIndex { get }
    static func getSize(sizes: TableSizes) -> Int
    init(reading: UnsafeRawBufferPointer, sizes: TableSizes)
}

public protocol KeyedTableRow: TableRow {
    associatedtype PrimaryKey: Comparable
    var primaryKey: PrimaryKey { get }
}

public protocol DoublyKeyedTableRow: KeyedTableRow {
    associatedtype SecondaryKey: Comparable
    var secondaryKey: SecondaryKey { get }
}
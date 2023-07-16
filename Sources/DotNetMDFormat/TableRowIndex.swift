/// A strongly-typed, 3-byte index of a metadata table row.
/// In CLI (§II.22), they are one-based where zero means a null row:
/// > Indexes to tables begin at 1, so index 1 means the first row in any given metadata table.
/// > (An index value of zero denotes that it does not index a row at all;
/// > that is, it behaves like a null reference.)
/// To leverage the Swift type system better, we represent them as zero-based
/// and use Optional<TableRowIndex> to represent nullability.
public struct TableRowIndex<Row>: Hashable, Comparable {
    // Imitate a UInt24 using 3 bytes since values never exceed 0xFF_FF_FF and so Optional<TableRowIndex> is 4 bytes.
    private let low16: UInt16
    private let high8: UInt8

    public var zeroBased: UInt32 { (UInt32(high8) << 16) | UInt32(low16) }
    public var oneBased: UInt32 { zeroBased + 1 }

    public init(zeroBased: UInt32) {
        precondition(zeroBased < 0xFF_FF_FF)
        self.low16 = UInt16(zeroBased & 0xFF_FF)
        self.high8 = UInt8((zeroBased >> 16) & 0xFF)
    }

    public init?(oneBased: UInt32) {
        precondition(oneBased < 0x1_00_00_00)
        guard oneBased != 0 else { return nil }
        self.init(zeroBased: oneBased - 1)
    }

    public static func < (lhs: TableRowIndex<Row>, rhs: TableRowIndex<Row>) -> Bool {
        return lhs.zeroBased < rhs.zeroBased
    }
}

extension TableRowIndex: Strideable {
    public typealias Stride = Int

    public func distance(to other: Self) -> Stride {
        Int(other.zeroBased) - Int(zeroBased)
    }

    public func advanced(by n: Stride) -> Self {
        .init(zeroBased: UInt32(Int(zeroBased) + n))
    }
}
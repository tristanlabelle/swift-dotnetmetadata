/// Represent a coded index, i.e. a row index into one of several metadata tables based on a tag value.
/// Can also represent a null index into a specific metadata table.
/// See ECMA-335 §II.24.2.6: "Coded indices".
public struct CodedIndex<Tag: CodedIndexTag>: Hashable, Comparable {
    public typealias Tag = Tag

    public let value: UInt32

    public init(value: UInt32) {
        self.value = value
    }

    public init(tag: Tag, rowIndex: TableRowIndex?) {
        self.init(value: (rowIndex.oneBased << Tag.bitCount) | UInt32(tag.rawValue))
    }

    public static func null(tag: Tag) -> CodedIndex { .init(tag: tag, rowIndex: nil) }

    public var rowIndex: TableRowIndex? { TableRowIndex(oneBased: value >> Tag.bitCount) }
    public var isNull: Bool { rowIndex == nil }

    public var tag: Tag {
        get throws {
            try Tag(value: UInt8(value & Tag.bitMask))
        }
    }

    public var metadataToken: MetadataToken {
        get throws {
            let rawTag = Int(value & Tag.bitMask)
            guard rawTag < Tag.tables.count, let tableID = Tag.tables[rawTag] else {
                throw InvalidFormatError.tableConstraint
            }
            return MetadataToken(tableID: tableID, rowIndex: rowIndex)
        }
    }

    public static func < (lhs: CodedIndex<Tag>, rhs: CodedIndex<Tag>) -> Bool {
        lhs.value < rhs.value
    }
}

/// Protocol for an enum which identifies one of several metadata tables that a coded index can point to.
public protocol CodedIndexTag: Hashable, RawRepresentable where RawValue == UInt8 {
    static var tables: [TableID?] { get }
    init(value: UInt8) throws
}

extension CodedIndexTag {
    // ECMA-335 §II.24.2.6: "The actual table is encoded into the low [N] bits of the number"
    public static var bitCount: Int { Int.bitWidth - (tables.count - 1).leadingZeroBitCount }
    public static var bitMask: UInt32 { (UInt32(1) << bitCount) - 1 }
}
/// Represent a coded index, i.e. a row index into one of several metadata tables based on a tag value.
/// Can also represent a null index into a specific metadata table.
/// See ECMA-335 §II.24.2.6: "Coded indices".
public struct CodedIndex<Tag: CodedIndexTag>: Hashable, Comparable {
    public typealias Tag = Tag

    public let value: UInt32

    public init(value: UInt32) {
        self.value = value
    }

    public init(tag: Tag, oneBasedRowIndex: UInt32) {
        self.init(value: (oneBasedRowIndex << Tag.bitCount) | UInt32(tag.rawValue))
    }

    public init(tag: Tag, zeroBasedRowIndex: UInt32) {
        self.init(tag: tag, oneBasedRowIndex: zeroBasedRowIndex + 1)
    }

    public var oneBasedRowIndex: UInt32 {
        value >> Tag.bitCount
    }

    public var zeroBasedRowIndex: UInt32? {
        switch oneBasedRowIndex {
            case 0: return nil
            case let i: return i - 1
        }
    }

    public var isNull: Bool { oneBasedRowIndex == 0 }

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
            return MetadataToken(tableID: tableID, oneBasedRowIndex: oneBasedRowIndex)
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
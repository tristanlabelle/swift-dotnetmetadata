import Testing
@testable import DotNetMetadataFormat

struct TableColumnSizeTests {
    @Test func testCodedIndexEnumTagBitCount() throws {
        enum TwoCaseCodedIndexTag: UInt8, CodedIndexTag {
            case case1, case2
            static let tables: [TableID?] = [ nil, nil ]
            init(value: UInt8) throws { fatalError() }
        }

        #expect(TwoCaseCodedIndexTag.bitCount == 1)

        enum ThreeCaseCodedIndexTag: UInt8, CodedIndexTag {
            case case1, case2, case3
            static let tables: [TableID?] = [ nil, nil, nil ]
            init(value: UInt8) throws { fatalError() }
        }

        #expect(ThreeCaseCodedIndexTag.bitCount == 2)

        enum FourCaseCodedIndexTag: UInt8, CodedIndexTag {
            case case1, case2, case3, case4
            static let tables: [TableID?] = [ nil, nil, nil, nil ]
            init(value: UInt8) throws { fatalError() }
        }

        #expect(FourCaseCodedIndexTag.bitCount == 2)
    }

    @Test func testRowIndexSize() throws {
        func getRowIndexSize(rowCount: UInt32) -> Int {
            let tableID = TableID.typeDef
            var tableRowCounts = Array(repeating: UInt32(0), count: TableID.count)
            tableRowCounts[tableID.intValue] = rowCount
            return TableSizes(heapSizingBits: 0, tableRowCounts: tableRowCounts).getTableRowIndexSize(tableID)
        }

        #expect(getRowIndexSize(rowCount: 0) == 2)
        #expect(getRowIndexSize(rowCount: 1) == 2)
        #expect(getRowIndexSize(rowCount: 0x100) == 2)
        #expect(getRowIndexSize(rowCount: 0x1000) == 2)
        #expect(getRowIndexSize(rowCount: 0xFFFE) == 2)
        #expect(getRowIndexSize(rowCount: 0x10001) == 4)
    }

    @Test func testAttributeEnumSize() throws {
        #expect(MemoryLayout<FieldAttributes>.stride == MemoryLayout<FieldAttributes.RawValue>.stride)
        #expect(MemoryLayout<FieldAttributes>.stride == 2)
    }
}

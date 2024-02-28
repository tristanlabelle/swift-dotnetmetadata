import XCTest
@testable import DotNetMetadataFormat

final class TableColumnSizeTests: XCTestCase {
    func testCodedIndexEnumTagBitCount() throws {
        enum TwoCaseCodedIndexTag: UInt8, CodedIndexTag {
            case case1, case2
            static let tables: [TableID?] = [ nil, nil ]
            init(value: UInt8) throws { fatalError() }
        }

        XCTAssertEqual(TwoCaseCodedIndexTag.bitCount, 1)

        enum ThreeCaseCodedIndexTag: UInt8, CodedIndexTag {
            case case1, case2, case3
            static let tables: [TableID?] = [ nil, nil, nil ]
            init(value: UInt8) throws { fatalError() }
        }

        XCTAssertEqual(ThreeCaseCodedIndexTag.bitCount, 2)

        enum FourCaseCodedIndexTag: UInt8, CodedIndexTag {
            case case1, case2, case3, case4
            static let tables: [TableID?] = [ nil, nil, nil, nil ]
            init(value: UInt8) throws { fatalError() }
        }

        XCTAssertEqual(FourCaseCodedIndexTag.bitCount, 2)
    }

    func testRowIndexSize() throws {
        func getRowIndexSize(rowCount: UInt32) -> Int {
            let tableID = TableID.typeDef
            var tableRowCounts = Array(repeating: UInt32(0), count: TableID.count)
            tableRowCounts[tableID.intValue] = rowCount
            return TableSizes(heapSizingBits: 0, tableRowCounts: tableRowCounts).getTableRowIndexSize(tableID)
        }

        XCTAssertEqual(getRowIndexSize(rowCount: 0), 2)
        XCTAssertEqual(getRowIndexSize(rowCount: 1), 2)
        XCTAssertEqual(getRowIndexSize(rowCount: 0x100), 2)
        XCTAssertEqual(getRowIndexSize(rowCount: 0x1000), 2)
        XCTAssertEqual(getRowIndexSize(rowCount: 0xFFFE), 2)
        XCTAssertEqual(getRowIndexSize(rowCount: 0x10001), 4)
    }

    func testAttributeEnumSize() throws {
        XCTAssertEqual(MemoryLayout<FieldAttributes>.stride, MemoryLayout<FieldAttributes.RawValue>.stride)
        XCTAssertEqual(MemoryLayout<FieldAttributes>.stride, 2)
    }
}

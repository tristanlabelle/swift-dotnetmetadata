import Foundation
import XCTest
@testable import WinMD

final class TableColumnSizeTests: XCTestCase {
    func testCodedIndexTagBitCount() throws {
        enum TwoCaseCodedIndex: CodedIndex {
            public static let tables: [TableIndex?] = [ nil, nil ]
            public init(tag: UInt8, oneBasedIndex: UInt32) { fatalError() }
        }

        XCTAssertEqual(TwoCaseCodedIndex.tagBitCount, 1)
        
        enum ThreeCaseCodedIndex: CodedIndex {
            public static let tables: [TableIndex?] = [ nil, nil, nil ]
            public init(tag: UInt8, oneBasedIndex: UInt32) { fatalError() }
        }

        XCTAssertEqual(ThreeCaseCodedIndex.tagBitCount, 2)

        enum FourCaseCodedIndex: CodedIndex {
            public static let tables: [TableIndex?] = [ nil, nil, nil, nil ]
            public init(tag: UInt8, oneBasedIndex: UInt32) { fatalError() }
        }

        XCTAssertEqual(FourCaseCodedIndex.tagBitCount, 2)
    }

    func testRowIndexSize() throws {
        func getRowIndexSize(rowCount: UInt32) -> Int {
            let tableIndex = TableIndex.typeDef
            var tableRowCounts = Array(repeating: UInt32(0), count: TableIndex.count)
            tableRowCounts[tableIndex.intValue] = rowCount
            return TableSizes(heapSizingBits: 0, tableRowCounts: tableRowCounts).getTableRowIndexSize(tableIndex)
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

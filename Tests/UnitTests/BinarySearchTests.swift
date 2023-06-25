import XCTest
@testable import DotNetMDFormat

final class BinarySearchTests: XCTestCase {
    func test() {
        let list = [ "B", "C", "E" ]
        XCTAssertEqual(list.binarySearchIndex(isBefore: { $0 < "A" }), 0)
        XCTAssertEqual(list.binarySearchIndex(isBefore: { $0 < "B" }), 0)
        XCTAssertEqual(list.binarySearchIndex(isBefore: { $0 < "C" }), 1)
        XCTAssertEqual(list.binarySearchIndex(isBefore: { $0 < "D" }), 2)
        XCTAssertEqual(list.binarySearchIndex(isBefore: { $0 < "E" }), 2)
        XCTAssertEqual(list.binarySearchIndex(isBefore: { $0 < "F" }), 3)
    }
}
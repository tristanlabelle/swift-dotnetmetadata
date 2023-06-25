import XCTest
@testable import DotNetMDFormat

final class BinarySearchTests: XCTestCase {
    func test() {
        let list = [ "B", "C", "E" ]
        XCTAssertEqual(list.binarySearch("A"), .absent(insertAt: 0))
        XCTAssertEqual(list.binarySearch("B"), .present(at: 0))
        XCTAssertEqual(list.binarySearch("C"), .present(at: 1))
        XCTAssertEqual(list.binarySearch("D"), .absent(insertAt: 2))
        XCTAssertEqual(list.binarySearch("E"), .present(at: 2))
        XCTAssertEqual(list.binarySearch("F"), .absent(insertAt: 3))
    }
}
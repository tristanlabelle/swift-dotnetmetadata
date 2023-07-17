import XCTest
@testable import DotNetMDFormat

final class BinarySearchTests: XCTestCase {
    func testOddCount() {
        let list = [ "B", "C", "E" ]
        XCTAssertEqual(list.binarySearch(for: "A"), .absent(insertAt: 0))
        XCTAssertEqual(list.binarySearch(for: "B"), .present(at: 0))
        XCTAssertEqual(list.binarySearch(for: "C"), .present(at: 1))
        XCTAssertEqual(list.binarySearch(for: "D"), .absent(insertAt: 2))
        XCTAssertEqual(list.binarySearch(for: "E"), .present(at: 2))
        XCTAssertEqual(list.binarySearch(for: "F"), .absent(insertAt: 3))
    }

    func testEvenCount() {
        let list = [ "B", "D" ]
        XCTAssertEqual(list.binarySearch(for: "A"), .absent(insertAt: 0))
        XCTAssertEqual(list.binarySearch(for: "B"), .present(at: 0))
        XCTAssertEqual(list.binarySearch(for: "C"), .absent(insertAt: 1))
        XCTAssertEqual(list.binarySearch(for: "D"), .present(at: 1))
        XCTAssertEqual(list.binarySearch(for: "E"), .absent(insertAt: 2))
    }
}
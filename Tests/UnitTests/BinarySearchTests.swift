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

    func testMatchPreference() {
        let listAAB = [ "A", "A", "B" ]
        XCTAssertEqual(listAAB.binarySearch(for: "A", matchPreference: .first), .present(at: 0))
        XCTAssertEqual(listAAB.binarySearch(for: "A", matchPreference: .last), .present(at: 1))

        let listABB = [ "A", "B", "B" ]
        XCTAssertEqual(listABB.binarySearch(for: "B", matchPreference: .first), .present(at: 1))
        XCTAssertEqual(listABB.binarySearch(for: "B", matchPreference: .last), .present(at: 2))
    }

    func testRange() {
        let list = [ "A", "B", "B", "D" ]
        XCTAssertEqual(list.binarySearchRange(for: "B"), 1..<3)
        XCTAssertEqual(list.binarySearchRange(for: "C"), 3..<3)
    }
}
import XCTest
@testable import DotNetMDFormat

final class BinarySearchTests: XCTestCase {
    func test() {
        let list = [ "B", "C", "E" ]
        XCTAssertEqual(list.binarySearch(for: "A"), .absent(insertAt: 0))
        XCTAssertEqual(list.binarySearch(for: "B"), .present(at: 0))
        XCTAssertEqual(list.binarySearch(for: "C"), .present(at: 1))
        XCTAssertEqual(list.binarySearch(for: "D"), .absent(insertAt: 2))
        XCTAssertEqual(list.binarySearch(for: "E"), .present(at: 2))
        XCTAssertEqual(list.binarySearch(for: "F"), .absent(insertAt: 3))
    }
}
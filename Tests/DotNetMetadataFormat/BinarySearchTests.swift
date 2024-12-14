import Testing
@testable import DotNetMetadataFormat

struct BinarySearchTests {
    @Test func testOddCount() {
        let list = [ "B", "C", "E" ]
        #expect(list.binarySearch(for: "A") == .absent(insertAt: 0))
        #expect(list.binarySearch(for: "B") == .present(at: 0))
        #expect(list.binarySearch(for: "C") == .present(at: 1))
        #expect(list.binarySearch(for: "D") == .absent(insertAt: 2))
        #expect(list.binarySearch(for: "E") == .present(at: 2))
        #expect(list.binarySearch(for: "F") == .absent(insertAt: 3))
    }

    @Test func testEvenCount() {
        let list = [ "B", "D" ]
        #expect(list.binarySearch(for: "A") == .absent(insertAt: 0))
        #expect(list.binarySearch(for: "B") == .present(at: 0))
        #expect(list.binarySearch(for: "C") == .absent(insertAt: 1))
        #expect(list.binarySearch(for: "D") == .present(at: 1))
        #expect(list.binarySearch(for: "E") == .absent(insertAt: 2))
    }

    @Test func testMatchPreference() {
        let listAAB = [ "A", "A", "B" ]
        #expect(listAAB.binarySearch(for: "A", matchPreference: .first) == .present(at: 0))
        #expect(listAAB.binarySearch(for: "A", matchPreference: .last) == .present(at: 1))

        let listABB = [ "A", "B", "B" ]
        #expect(listABB.binarySearch(for: "B", matchPreference: .first) == .present(at: 1))
        #expect(listABB.binarySearch(for: "B", matchPreference: .last) == .present(at: 2))
    }

    @Test func testRange() {
        let list = [ "A", "B", "B", "D" ]
        #expect(list.binarySearchRange(for: "B") == 1..<3)
        #expect(list.binarySearchRange(for: "C") == 3..<3)
    }
}
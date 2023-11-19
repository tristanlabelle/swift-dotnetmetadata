@testable import DotNetXMLDocs
import XCTest

final class DocumentationTypeNodeTests: XCTestCase {
    func testParseBound() throws {
        XCTAssertEqual(
            try DocumentationTypeNode(parsing: "Name"),
            .bound(nameWithoutGenericSuffix: "Name"))
    }

    func testParseArray() throws {
        XCTAssertEqual(
            try DocumentationTypeNode(parsing: "Name[]"),
            .array(of: .bound(nameWithoutGenericSuffix: "Name")))
    }

    func testParsePointer() throws {
        XCTAssertEqual(
            try DocumentationTypeNode(parsing: "Name*"),
            .pointer(to: .bound(nameWithoutGenericSuffix: "Name")))
    }

    func testParseGenericParam() throws {
        XCTAssertEqual(
            try DocumentationTypeNode(parsing: "`0"),
            .genericParam(index: 0, kind: .type))
        XCTAssertEqual(
            try DocumentationTypeNode(parsing: "``42"),
            .genericParam(index: 42, kind: .method))
    }
}
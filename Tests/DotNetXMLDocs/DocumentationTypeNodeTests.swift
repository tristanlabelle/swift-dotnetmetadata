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

    func testParseGenericArg() throws {
        XCTAssertEqual(
            try DocumentationTypeNode(parsing: "`42"),
            .genericArg(index: 42, kind: .type))
        XCTAssertEqual(
            try DocumentationTypeNode(parsing: "``42"),
            .genericArg(index: 42, kind: .method))
    }
}
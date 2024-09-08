@testable import DotNetXMLDocs
import XCTest

final class DocumentationTypeNodeTests: XCTestCase {
    func testParseBound() throws {
        XCTAssertEqual(
            try DocumentationTypeNode(parsing: "Name"),
            .bound(nameWithoutGenericArity: "Name"))
    }

    func testParseArray() throws {
        XCTAssertEqual(
            try DocumentationTypeNode(parsing: "Name[]"),
            .array(of: .bound(nameWithoutGenericArity: "Name")))
    }

    func testParsePointer() throws {
        XCTAssertEqual(
            try DocumentationTypeNode(parsing: "Name*"),
            .pointer(to: .bound(nameWithoutGenericArity: "Name")))
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
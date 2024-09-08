@testable import DotNetXMLDocs
import XCTest

final class DocumentationTypeReferenceTests: XCTestCase {
    func testParseNonGeneric() throws {
        XCTAssertEqual(
            try DocumentationTypeReference(parsing: "Name"),
            .init(nameWithoutGenericArity: "Name"))
    }

    func testParseUnboundGeneric() throws {
        XCTAssertEqual(
            try DocumentationTypeReference(parsing: "Name`1"),
            .init(nameWithoutGenericArity: "Name", genericity: .unbound(arity: 1)))
    }

    func testParseBoundGeneric() throws {
        XCTAssertEqual(
            try DocumentationTypeReference(parsing: "Name`1{Name2}"),
            .init(nameWithoutGenericArity: "Name", genericArgs: [ .bound(nameWithoutGenericArity: "Name2") ]))
    }

    func testParseNamespaced() throws {
        XCTAssertEqual(
            try DocumentationTypeReference(parsing: "Namespace.Name"),
            .init(namespace: "Namespace", nameWithoutGenericArity: "Name"))
    }
}
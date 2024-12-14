@testable import DotNetXMLDocs
import Testing

struct DocumentationTypeNodeTests {
    @Test func testParseBound() throws {
        #expect(try DocumentationTypeNode(parsing: "Name") == .bound(nameWithoutGenericArity: "Name"))
    }

    @Test func testParseArray() throws {
        #expect(try DocumentationTypeNode(parsing: "Name[]") == .array(of: .bound(nameWithoutGenericArity: "Name")))
    }

    @Test func testParsePointer() throws {
        #expect(try DocumentationTypeNode(parsing: "Name*") == .pointer(to: .bound(nameWithoutGenericArity: "Name")))
    }

    @Test func testParseGenericParam() throws {
        #expect(try DocumentationTypeNode(parsing: "`0") == .genericParam(index: 0, kind: .type))
        #expect(try DocumentationTypeNode(parsing: "``42") == .genericParam(index: 42, kind: .method))
    }
}
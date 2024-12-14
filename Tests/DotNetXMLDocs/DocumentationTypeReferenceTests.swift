@testable import DotNetXMLDocs
import Testing

struct DocumentationTypeReferenceTests {
    @Test func testParseNonGeneric() throws {
        #expect(try DocumentationTypeReference(parsing: "Name")
            == .init(nameWithoutGenericArity: "Name"))
    }

    @Test func testParseUnboundGeneric() throws {
        #expect(try DocumentationTypeReference(parsing: "Name`1")
            == .init(nameWithoutGenericArity: "Name", genericity: .unbound(arity: 1)))
    }

    @Test func testParseBoundGeneric() throws {
        #expect(try DocumentationTypeReference(parsing: "Name`1{Name2}")
            == .init(nameWithoutGenericArity: "Name", genericArgs: [ .bound(nameWithoutGenericArity: "Name2") ]))
    }

    @Test func testParseNamespaced() throws {
        #expect(try DocumentationTypeReference(parsing: "Namespace.Name")
            == .init(namespace: "Namespace", nameWithoutGenericArity: "Name"))
    }
}
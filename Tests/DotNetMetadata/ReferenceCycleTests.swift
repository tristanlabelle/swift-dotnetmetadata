@testable import DotNetMetadata
import XCTest

internal final class ReferenceCycleTests: XCTestCase {
    public func testNoLeak() throws {
        var compilation: CSharpCompilation! = try CSharpCompilation(code:
        """
        class Class { Class other; }
        """)

        weak var assembly = compilation.assembly
        weak var typeDefinition = try XCTUnwrap(XCTUnwrap(assembly).resolveTypeDefinition(fullName: "Class"))
        weak var field = try XCTUnwrap(XCTUnwrap(typeDefinition).findField(name: "other"))
        try XCTAssertEqual(XCTUnwrap(field).type, XCTUnwrap(typeDefinition).bindNode())
        
        // Reference cycle established: TypeDefinition > Field > TypeNode > BoundType > TypeDefinition
        XCTAssertNotNil(typeDefinition)
        XCTAssertNotNil(field)

        withExtendedLifetime(compilation) {}
        compilation = nil

        XCTAssertNil(assembly)
        XCTAssertNil(typeDefinition)
        XCTAssertNil(field)
    }
}
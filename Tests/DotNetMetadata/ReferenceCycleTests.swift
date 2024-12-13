@testable import DotNetMetadata
import Testing

internal struct ReferenceCycleTests {
    @Test func testNoLeak() throws {
        var compilation: CSharpCompilation = try CSharpCompilation(code:
        """
        class Class { Class other; }
        """)

        weak var assembly = compilation.assembly
        weak var typeDefinition = try #require(#require(assembly).resolveTypeDefinition(fullName: "Class"))
        weak var field = try #require(#require(typeDefinition).findField(name: "other"))
        #expect(try #require(field).type == #require(typeDefinition).bindNode())

        // Reference cycle established: TypeDefinition > Field > TypeNode > BoundType > TypeDefinition
        #expect(typeDefinition != nil)
        #expect(field != nil)

        withExtendedLifetime(compilation) {}
        compilation = nil

        #expect(assembly == nil)
        #expect(typeDefinition == nil)
        #expect(field == nil)
    }
}
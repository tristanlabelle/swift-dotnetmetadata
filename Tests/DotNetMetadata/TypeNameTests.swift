@testable import DotNetMetadata
import Testing

internal final class TypeNameTests {
    private var compilation: CSharpCompilation
    private var assembly: Assembly { compilation.assembly }

    init() throws {
        compilation = try CSharpCompilation(code: 
        """
        namespace Namespace.Nested { class Namespaced { class Nested {} } }
        class TopLevel {}
        class EnclosingGeneric<T> { class NestedGeneric<U> {} }
        """)
    }

    @Test func testNamespacedClass() throws {
        let classDefinition = try #require(try assembly.resolveTypeDefinition(fullName: "Namespace.Nested.Namespaced"))
        #expect(classDefinition.name == "Namespaced")
        #expect(classDefinition.namespace == "Namespace.Nested")
        #expect(classDefinition.fullName == "Namespace.Nested.Namespaced")
    }

    @Test func testNestedClass() throws {
        let classDefinition = try #require(try assembly.resolveTypeDefinition(fullName: "Namespace.Nested.Namespaced/Nested"))
        #expect(classDefinition.name == "Nested")
        #expect(classDefinition.namespace == nil)
        #expect(classDefinition.fullName == "Namespace.Nested.Namespaced/Nested")
    }

    @Test func testTopLevelClass() throws {
        let classDefinition = try #require(try assembly.resolveTypeDefinition(fullName: "TopLevel"))
        #expect(classDefinition.name == "TopLevel")
        #expect(classDefinition.namespace == nil)
        #expect(classDefinition.fullName == "TopLevel")
    }

    @Test func testGeneric() throws {
        let enclosingClass = try #require(try assembly.resolveTypeDefinition(fullName: "EnclosingGeneric`1"))
        #expect(enclosingClass.name == "EnclosingGeneric`1")

        let nestedClass = try #require(try assembly.resolveTypeDefinition(fullName: "EnclosingGeneric`1/NestedGeneric`1"))
        #expect(nestedClass.name == "NestedGeneric`1")
        #expect(nestedClass.fullName == "EnclosingGeneric`1/NestedGeneric`1")
    }
}
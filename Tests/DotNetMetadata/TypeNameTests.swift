@testable import DotNetMetadata
import XCTest

internal final class TypeNameTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        namespace Namespace.Nested { class Namespaced { class Nested {} } }
        class TopLevel {}
        class EnclosingGeneric<T> { class NestedGeneric<U> {} }
        """
    }

    public func testNamespacedClass() throws {
        let classDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Namespace.Nested.Namespaced"))
        XCTAssertEqual(classDefinition.name, "Namespaced")
        XCTAssertEqual(classDefinition.namespace, "Namespace.Nested")
        XCTAssertEqual(classDefinition.fullName, "Namespace.Nested.Namespaced")
    }

    public func testNestedClass() throws {
        let classDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Namespace.Nested.Namespaced/Nested"))
        XCTAssertEqual(classDefinition.name, "Nested")
        XCTAssertEqual(classDefinition.namespace, nil)
        XCTAssertEqual(classDefinition.fullName, "Namespace.Nested.Namespaced/Nested")
    }

    public func testTopLevelClass() throws {
        let classDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "TopLevel"))
        XCTAssertEqual(classDefinition.name, "TopLevel")
        XCTAssertEqual(classDefinition.namespace, nil)
        XCTAssertEqual(classDefinition.fullName, "TopLevel")
    }

    public func testGeneric() throws {
        let enclosingClass = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "EnclosingGeneric`1"))
        XCTAssertEqual(enclosingClass.name, "EnclosingGeneric`1")

        let nestedClass = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "EnclosingGeneric`1/NestedGeneric`1"))
        XCTAssertEqual(nestedClass.name, "NestedGeneric`1")
        XCTAssertEqual(nestedClass.fullName, "EnclosingGeneric`1/NestedGeneric`1")
    }
}
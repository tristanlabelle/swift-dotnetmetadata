@testable import DotNetMetadata
import XCTest

internal final class TypeDefinitionTests: XCTestCase {
    public func testTypeKinds() throws {
        let compilation = try CSharpCompilation(code:
        """
        interface Interface {}
        class Class {}
        delegate void Delegate();
        enum Enum {}
        struct Struct {}
        """)

        let assembly = compilation.assembly
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Interface") as? InterfaceDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Class") as? ClassDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Delegate") as? DelegateDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Enum") as? EnumDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Struct") as? StructDefinition)
    }

    public func testStructuralRelationships() throws {
        let compilation = try CSharpCompilation(code:
        """
        class Generic<T> {}
        class Base {}
        class Derived : Base {}
        interface Interface {}
        class Implementing : Interface {}
        class Enclosing { class Nested {} }
        """)

        let assembly = compilation.assembly

        // Base/derived
        let base = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Base"))
        let derived = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Derived"))
        try XCTAssertEqual(XCTUnwrap(derived.base), base.bindType())
        try XCTAssertEqual(XCTUnwrap(base.base), base.context.coreLibrary.systemObject.bindType())

        // Interface implementation
        let interface = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Interface"))
        let implementing = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Implementing"))
        try XCTAssertEqual(XCTUnwrap(implementing.baseInterfaces.first).interface.asBoundType, interface.bindType())

        // Nesting
        let enclosing = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Enclosing"))
        let nested = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Enclosing/Nested"))
        try XCTAssertEqual(XCTUnwrap(nested.enclosingType), enclosing)
        try XCTAssertEqual(XCTUnwrap(enclosing.nestedTypes.first), nested)
    }

    public func testVisibility() throws {
        let compilation = try CSharpCompilation(code:
        """
        internal class Internal {}
        public class Public {}
        class NestedVisibility
        {
            private class Private {}
            protected class Protected {}
            internal class Internal {}
            private protected class PrivateProtected {}
            protected internal class ProtectedInternal {}
            public class Public {}
        }
        """)

        func assertTypeVisibility(_ name: String, _ visibility: Visibility) throws {
            let typeDefinition = try XCTUnwrap(compilation.assembly.resolveTypeDefinition(fullName: name))
            XCTAssertEqual(typeDefinition.visibility, visibility)
        }

        try assertTypeVisibility("Internal", .assembly)
        try assertTypeVisibility("Public", .public)
        try assertTypeVisibility("NestedVisibility/Private", .private)
        try assertTypeVisibility("NestedVisibility/Protected", .family)
        try assertTypeVisibility("NestedVisibility/Internal", .assembly)
        try assertTypeVisibility("NestedVisibility/PrivateProtected", .familyAndAssembly)
        try assertTypeVisibility("NestedVisibility/ProtectedInternal", .familyOrAssembly)
        try assertTypeVisibility("NestedVisibility/Public", .public)
    }

    public func testModifiers() throws {
        let compilation = try CSharpCompilation(code:
        """
        class Open {}
        sealed class Sealed {}
        abstract class Abstract {}
        static class Static {}
        """)

        func assertTypeModifiers(_ name: String, abstract: Bool = false, sealed: Bool = false, static: Bool = false) throws {
            let typeDefinition = try XCTUnwrap(compilation.assembly.resolveTypeDefinition(fullName: name) as? ClassDefinition)
            XCTAssertEqual(typeDefinition.isAbstract, abstract)
            XCTAssertEqual(typeDefinition.isSealed, sealed)
            XCTAssertEqual(typeDefinition.isStatic, `static`)
        }

        try assertTypeModifiers("Open")
        try assertTypeModifiers("Sealed", sealed: true)
        try assertTypeModifiers("Abstract", abstract: true)
        try assertTypeModifiers("Static", abstract: true, sealed: true, static: true)
    }
}
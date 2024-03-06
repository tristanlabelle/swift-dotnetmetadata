@testable import DotNetMetadata
import XCTest

internal final class TypeDefinitionTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        // Type kinds
        interface Interface {}
        class Class {}
        delegate void Delegate();
        enum Enum {}
        struct Struct {}

        // Structural relationships
        class Generic<T> {}
        class Derived : Class {}
        class Implementing : Interface {}
        class Enclosing { class Nested {} }

        // Visibility
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

        // Modifiers
        class Open {}
        sealed class Sealed {}
        abstract class Abstract {}
        static class Static {}
        """
    }

    public func testTypeKinds() throws {
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Interface") as? InterfaceDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Class") as? ClassDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Delegate") as? DelegateDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Enum") as? EnumDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Struct") as? StructDefinition)
    }

    public func testBaseClass() throws {
        let `class` = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Class"))
        let derivedClass = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Derived"))
        try XCTAssertEqual(XCTUnwrap(derivedClass.base), `class`.bindType())
        try XCTAssertEqual(XCTUnwrap(`class`.base), `class`.context.coreLibrary.systemObject.bindType())
    }

    public func testImplementedInterface() throws {
        let implementingClass = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Implementing"))
        try XCTAssertEqual(
            XCTUnwrap(implementingClass.baseInterfaces.first).interface.asBoundType,
            XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Interface")).bindType())
    }

    public func testClassNesting() throws {
        let enclosingClass = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Enclosing"))
        let nestedClass = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Enclosing/Nested"))
        try XCTAssertEqual(XCTUnwrap(nestedClass.enclosingType), enclosingClass)
        try XCTAssertEqual(XCTUnwrap(enclosingClass.nestedTypes.first), nestedClass)
    }

    public func testVisibility() throws {
        func assertTypeVisibility(_ name: String, _ visibility: Visibility) throws {
            let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: name))
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
        func assertTypeModifiers(_ name: String, abstract: Bool = false, sealed: Bool = false, static: Bool = false) throws {
            let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: name) as? ClassDefinition)
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
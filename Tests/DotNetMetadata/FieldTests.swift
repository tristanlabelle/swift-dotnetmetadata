@testable import DotNetMetadata
import XCTest

internal final class FieldTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        class Enumeration
        {
            bool A;
            bool B;
            bool C;
        }

        class Modifiers
        {
            bool Instance;
            readonly bool InitOnly;
            static bool Static;
            static readonly bool StaticInitOnly;
            const bool Literal = false;
        }

        class LiteralValues
        {
            const bool Bool = true;
            const int Int = 42;
            const float Float = 42;
            const string String = "Hello, World!";
            const object Null = null;
        }

        class Visibility
        {
            private bool Private;
            protected bool Protected;
            internal bool Internal;
            private protected bool PrivateProtected;
            protected internal bool ProtectedInternal;
            public bool Public;
        }
        """
    }

    public func testEnumeration() throws {
        let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Enumeration"))
        XCTAssertEqual(typeDefinition.fields.map { $0.name }, ["A", "B", "C"])
    }

    public func testName() throws {
        let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Enumeration"))
        let field = try XCTUnwrap(typeDefinition.findField(name: "A"))
        XCTAssertEqual(field.name, "A")
    }

    public func testType() throws {
        // Additional tests in TypeTests
        let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Enumeration"))
        let field = try XCTUnwrap(typeDefinition.findField(name: "A"))
        try XCTAssertEqual(field.type, assembly.context.coreLibrary.systemBoolean.bindNode())
    }

    public func testModifiers() throws {
        let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Modifiers"))

        func assertModifiers(_ name: String, static: Bool = false, initOnly: Bool = false, literal: Bool = false) throws {
            let field = try XCTUnwrap(typeDefinition.findField(name: name))
            XCTAssertEqual(field.isStatic, `static`)
            XCTAssertEqual(field.isInstance, !`static`)
            XCTAssertEqual(field.isInitOnly, initOnly)
            XCTAssertEqual(field.isLiteral, literal)
        }

        try assertModifiers("Instance")
        try assertModifiers("InitOnly", initOnly: true)
        try assertModifiers("Static", static: true)
        try assertModifiers("StaticInitOnly", static: true, initOnly: true)
        try assertModifiers("Literal", static: true, literal: true)
    }

    public func testLiteralValues() throws {
        let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "LiteralValues"))
        try XCTAssertEqual(XCTUnwrap(typeDefinition.findField(name: "Bool")).literalValue, .boolean(true))
        try XCTAssertEqual(XCTUnwrap(typeDefinition.findField(name: "Int")).literalValue, .int32(42))
        try XCTAssertEqual(XCTUnwrap(typeDefinition.findField(name: "Float")).literalValue, .single(42))
        try XCTAssertEqual(XCTUnwrap(typeDefinition.findField(name: "String")).literalValue, .string("Hello, World!"))
        try XCTAssertEqual(XCTUnwrap(typeDefinition.findField(name: "Null")).literalValue, .null)
    }

    public func testVisibility() throws {
        let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Visibility"))

        func assertVisibility(_ name: String, _ visibility: Visibility) throws {
            let field = try XCTUnwrap(typeDefinition.findField(name: name))
            XCTAssertEqual(field.visibility, visibility)
        }

        try assertVisibility("Private", .private)
        try assertVisibility("Protected", .family)
        try assertVisibility("Internal", .assembly)
        try assertVisibility("PrivateProtected", .familyAndAssembly)
        try assertVisibility("ProtectedInternal", .familyOrAssembly)
        try assertVisibility("Public", .public)
    }
}
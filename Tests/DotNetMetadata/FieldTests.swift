@testable import DotNetMetadata
import Testing

internal struct FieldTests {
    @Test func testEnumerationAndName() throws {
        let compilation = try CSharpCompilation(code:
        """
        class Type
        {
            bool A;
            bool B;
            bool C;
        }
        """)

        let typeDefinition = try #require(compilation.assembly.resolveTypeDefinition(fullName: "Type"))
        #expect(typeDefinition.fields.map { $0.name } == ["A", "B", "C"])
    }

    @Test func testType() throws {
        // See TypeTests
    }

    @Test func testModifiers() throws {
        let compilation = try CSharpCompilation(code:
        """
        class Type
        {
            bool Instance;
            readonly bool InitOnly;
            static bool Static;
            static readonly bool StaticInitOnly;
            const bool Literal = false;
        }
        """)

        let typeDefinition = try #require(compilation.assembly.resolveTypeDefinition(fullName: "Type"))

        func assertModifiers(_ name: String, static: Bool = false, initOnly: Bool = false, literal: Bool = false) throws {
            let field = try #require(try typeDefinition.findField(name: name))
            #expect(field.isStatic == `static`)
            #expect(field.isInstance == !`static`)
            #expect(field.isInitOnly == initOnly)
            #expect(field.isLiteral == literal)
        }

        try assertModifiers("Instance")
        try assertModifiers("InitOnly", initOnly: true)
        try assertModifiers("Static", static: true)
        try assertModifiers("StaticInitOnly", static: true, initOnly: true)
        try assertModifiers("Literal", static: true, literal: true)
    }

    @Test func testLiteralValues() throws {
        let compilation = try CSharpCompilation(code:
        """
        class Type
        {
            const bool Bool = true;
            const int Int = 42;
            const float Float = 42;
            const string String = "Hello, World!";
            const object Null = null;
        }
        """)

        let typeDefinition = try #require(compilation.assembly.resolveTypeDefinition(fullName: "Type"))
        #expect(try #require(try typeDefinition.findField(name: "Bool")).literalValue == .boolean(true))
        #expect(try #require(try typeDefinition.findField(name: "Int")).literalValue == .int32(42))
        #expect(try #require(try typeDefinition.findField(name: "Float")).literalValue == .single(42))
        #expect(try #require(try typeDefinition.findField(name: "String")).literalValue == .string("Hello, World!"))
        #expect(try #require(try typeDefinition.findField(name: "Null")).literalValue == .null)
    }

    @Test func testVisibility() throws {
        let compilation = try CSharpCompilation(code:
        """
        class Type
        {
            private bool Private;
            protected bool Protected;
            internal bool Internal;
            private protected bool PrivateProtected;
            protected internal bool ProtectedInternal;
            public bool Public;
        }
        """)

        let typeDefinition = try #require(compilation.assembly.resolveTypeDefinition(fullName: "Type"))

        func assertVisibility(_ name: String, _ visibility: Visibility) throws {
            let field = try #require(try typeDefinition.findField(name: name))
            #expect(field.visibility == visibility)
        }

        try assertVisibility("Private", .private)
        try assertVisibility("Protected", .family)
        try assertVisibility("Internal", .assembly)
        try assertVisibility("PrivateProtected", .familyAndAssembly)
        try assertVisibility("ProtectedInternal", .familyOrAssembly)
        try assertVisibility("Public", .public)
    }
}
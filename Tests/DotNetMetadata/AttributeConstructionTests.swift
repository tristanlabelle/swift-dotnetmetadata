@testable import DotNetMetadata
import Testing

internal final class AttributeConstructionTests {
    private var compilation: CSharpCompilation
    private var assembly: Assembly { compilation.assembly }

    init() throws {
        compilation = try CSharpCompilation(code: 
        """
        class MyAttributeAttribute: System.Attribute
        {
            public MyAttributeAttribute() {}
            public MyAttributeAttribute(int i) {}
            public MyAttributeAttribute(string s) {}
            public MyAttributeAttribute(System.Type t) {}
            public MyAttributeAttribute(ShortEnum e) {}
            public int Field;
            public int Property { get; set; }
        }

        enum ShortEnum: short { A = 42 } // We should resolve the enum underlying type when decoding

        // Test attribute arguments
        [MyAttribute(1)] struct IntArgument {}
        [MyAttribute("1")] struct StringArgument {}
        [MyAttribute(typeof(TypeArgument))] struct TypeArgument {}
        [MyAttribute(ShortEnum.A)] struct EnumArgument {}
        [MyAttribute(Field = 42)] struct NamedFieldArgument {}
        [MyAttribute(Property = 42)] struct NamedPropertyArgument {}
        """)
    }

    @Test func testNumericArgument() throws {
        let targetType = try #require(assembly.resolveTypeDefinition(fullName: "IntArgument"))
        let attribute = try #require(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        let arguments = try attribute.arguments
        #expect(arguments.count == 1)
        #expect(try attribute.namedArguments.count == 0)
        guard case .constant(.int32(let i)) = arguments.first else {
            Issue.record("Expected int32")
            return
        }
        #expect(i == 1)
    }

    @Test func testStringArgument() throws {
        let targetType = try #require(assembly.resolveTypeDefinition(fullName: "StringArgument"))
        let attribute = try #require(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        let arguments = try attribute.arguments
        #expect(arguments.count == 1)
        #expect(try attribute.namedArguments.count == 0)
        guard case .constant(.string(let s)) = arguments.first else {
            Issue.record("Expected string")
            return
        }
        #expect(s == "1")
    }

    @Test func testTypeArgument() throws {
        let targetType = try #require(assembly.resolveTypeDefinition(fullName: "TypeArgument"))
        let attribute = try #require(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        let arguments = try attribute.arguments
        #expect(arguments.count == 1)
        #expect(try attribute.namedArguments.count == 0)
        guard case .type(let type) = arguments.first else {
            Issue.record("Expected type")
            return
        }
        #expect(type === targetType)
    }

    @Test func testEnumArgument() throws {
        let targetType = try #require(assembly.resolveTypeDefinition(fullName: "EnumArgument"))
        let attribute = try #require(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        let arguments = try attribute.arguments
        #expect(arguments.count == 1)
        #expect(try attribute.namedArguments.count == 0)
        guard case .constant(.int16(let i)) = arguments.first else {
            Issue.record("Expected int16")
            return
        }
        #expect(i == 42)
    }

    @Test func testNamedFieldArgument() throws {
        let targetType = try #require(assembly.resolveTypeDefinition(fullName: "NamedFieldArgument"))
        let attribute = try #require(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        #expect(try attribute.arguments.count == 0)
        let namedArguments = try attribute.namedArguments
        #expect(namedArguments.count == 1)
        let namedArgument = try #require(namedArguments.first)

        guard case .field(let field) = namedArgument.target else {
            Issue.record("Expected field")
            return
        }
        #expect(field.name == "Field")

        guard case .constant(.int32(let value)) = namedArgument.value else {
            Issue.record("Expected int32")
            return
        }
        #expect(value == 42)
    }

    @Test func testNamedPropertyArgument() throws {
        let targetType = try #require(assembly.resolveTypeDefinition(fullName: "NamedPropertyArgument"))
        let attribute = try #require(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        #expect(try attribute.arguments.count == 0)
        let namedArguments = try attribute.namedArguments
        #expect(namedArguments.count == 1)
        let namedArgument = try #require(namedArguments.first)

        guard case .property(let property) = namedArgument.target else {
            Issue.record("Expected property")
            return
        }
        #expect(property.name == "Property")

        guard case .constant(.int32(let value)) = namedArgument.value else {
            Issue.record("Expected int32")
            return
        }
        #expect(value == 42)
    }
}
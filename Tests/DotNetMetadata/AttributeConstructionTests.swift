@testable import DotNetMetadata
import XCTest

internal final class AttributeConstructionTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        class MyAttributeAttribute: System.Attribute
        {
            public MyAttributeAttribute() {}
            public MyAttributeAttribute(int i) {}
            public MyAttributeAttribute(string s) {}
            public MyAttributeAttribute(System.Type t) {}
            public MyAttributeAttribute(MyEnum e) {}
            public int Field;
            public int Property { get; set; }
        }

        enum MyEnum { A = 42 }

        // Test attribute arguments
        [MyAttribute(1)] struct IntArgument {}
        [MyAttribute("1")] struct StringArgument {}
        [MyAttribute(typeof(TypeArgument))] struct TypeArgument {}
        [MyAttribute(MyEnum.A)] struct EnumArgument {}
        [MyAttribute(Field = 42)] struct NamedFieldArgument {}
        [MyAttribute(Property = 42)] struct NamedPropertyArgument {}
        """
    }

    public func testNumericArgument() throws {
        let targetType = try XCTUnwrap(assembly.findDefinedType(fullName: "IntArgument"))
        let attribute = try XCTUnwrap(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        let arguments = try attribute.arguments
        XCTAssertEqual(arguments.count, 1)
        XCTAssertEqual(try attribute.namedArguments.count, 0)
        guard case .constant(.int32(let i)) = arguments.first else {
            XCTFail("Expected int32")
            return
        }
        XCTAssertEqual(i, 1)
    }

    public func testStringArgument() throws {
        let targetType = try XCTUnwrap(assembly.findDefinedType(fullName: "StringArgument"))
        let attribute = try XCTUnwrap(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        let arguments = try attribute.arguments
        XCTAssertEqual(arguments.count, 1)
        XCTAssertEqual(try attribute.namedArguments.count, 0)
        guard case .constant(.string(let s)) = arguments.first else {
            XCTFail("Expected string")
            return
        }
        XCTAssertEqual(s, "1")
    }

    public func testTypeArgument() throws {
        let targetType = try XCTUnwrap(assembly.findDefinedType(fullName: "TypeArgument"))
        let attribute = try XCTUnwrap(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        let arguments = try attribute.arguments
        XCTAssertEqual(arguments.count, 1)
        XCTAssertEqual(try attribute.namedArguments.count, 0)
        guard case .type(let type) = arguments.first else {
            XCTFail("Expected type")
            return
        }
        XCTAssertIdentical(type, targetType)
    }

    public func testEnumArgument() throws {
        let targetType = try XCTUnwrap(assembly.findDefinedType(fullName: "EnumArgument"))
        let attribute = try XCTUnwrap(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        let arguments = try attribute.arguments
        XCTAssertEqual(arguments.count, 1)
        XCTAssertEqual(try attribute.namedArguments.count, 0)
        guard case .constant(.int32(let i)) = arguments.first else {
            XCTFail("Expected int32")
            return
        }
        XCTAssertEqual(i, 42)
    }

    public func testNamedFieldArgument() throws {
        let targetType = try XCTUnwrap(assembly.findDefinedType(fullName: "NamedFieldArgument"))
        let attribute = try XCTUnwrap(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        XCTAssertEqual(try attribute.arguments.count, 0)
        let namedArguments = try attribute.namedArguments
        XCTAssertEqual(namedArguments.count, 1)
        let namedArgument = try XCTUnwrap(namedArguments.first)

        guard case .field(let field) = namedArgument.target else {
            XCTFail("Expected field")
            return
        }
        XCTAssertEqual(field.name, "Field")

        guard case .constant(.int32(let value)) = namedArgument.value else {
            XCTFail("Expected int32")
            return
        }
        XCTAssertEqual(value, 42)
    }

    public func testNamedPropertyArgument() throws {
        let targetType = try XCTUnwrap(assembly.findDefinedType(fullName: "NamedPropertyArgument"))
        let attribute = try XCTUnwrap(targetType.findAttribute(namespace: nil, name: "MyAttributeAttribute"))
        XCTAssertEqual(try attribute.arguments.count, 0)
        let namedArguments = try attribute.namedArguments
        XCTAssertEqual(namedArguments.count, 1)
        let namedArgument = try XCTUnwrap(namedArguments.first)

        guard case .property(let property) = namedArgument.target else {
            XCTFail("Expected property")
            return
        }
        XCTAssertEqual(property.name, "Property")

        guard case .constant(.int32(let value)) = namedArgument.value else {
            XCTFail("Expected int32")
            return
        }
        XCTAssertEqual(value, 42)
    }
}
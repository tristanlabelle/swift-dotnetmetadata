@testable import DotNetMetadata
import XCTest

internal final class FieldTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        class Fields {
            public int PublicInstance;
            private static readonly int PrivateStaticInitOnly;
            protected const int ProtectedLiteral = 42;
        }
        """
    }

    private var typeDefinition: TypeDefinition!

    public override func setUpWithError() throws {
        try super.setUpWithError()
        typeDefinition = try XCTUnwrap(assembly.findDefinedType(fullName: "Fields"))
    }

    public func testEnumeration() throws {
        XCTAssertEqual(
            typeDefinition.fields.map { $0.name },
            ["PublicInstance", "PrivateStaticInitOnly", "ProtectedLiteral"])
    }

    public func testPublicInstanceFlags() throws {
        let field = try XCTUnwrap(typeDefinition.findField(name: "PublicInstance"))
        XCTAssertEqual(field.name, "PublicInstance")
        XCTAssertEqual(field.visibility, .public)
        XCTAssertEqual(field.isStatic, false)
        XCTAssertEqual(field.isInitOnly, false)
        XCTAssertEqual(field.isLiteral, false)
        XCTAssertEqual(try field.literalValue, nil)
    }

    public func testPrivateStaticInitOnlyFlags() throws {
        let field = try XCTUnwrap(typeDefinition.findField(name: "PrivateStaticInitOnly"))
        XCTAssertEqual(field.name, "PrivateStaticInitOnly")
        XCTAssertEqual(field.visibility, .private)
        XCTAssertEqual(field.isStatic, true)
        XCTAssertEqual(field.isInitOnly, true)
        XCTAssertEqual(field.isLiteral, false)
        XCTAssertEqual(try field.literalValue, nil)
    }

    public func testProtectedLiteralFlags() throws {
        let field = try XCTUnwrap(typeDefinition.findField(name: "ProtectedLiteral"))
        XCTAssertEqual(field.name, "ProtectedLiteral")
        XCTAssertEqual(field.visibility, .family)
        XCTAssertEqual(field.isStatic, true)
        XCTAssertEqual(field.isInitOnly, false)
        XCTAssertEqual(field.isLiteral, true)
        XCTAssertEqual(try field.literalValue, Constant.int32(42))
    }
}
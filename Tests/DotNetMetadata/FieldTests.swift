@testable import DotNetMetadata
import XCTest

internal final class FieldTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        struct FieldType {}
        class Fields {
            public FieldType PublicInstance;
            private static readonly int PrivateStaticInitOnly;
            protected const int ProtectedLiteral = 42;
        }
        """
    }

    private var typeDefinition: TypeDefinition!
    private var publicInstanceField: Field!
    private var privateStaticInitOnlyField: Field!
    private var protectedLiteralField: Field!

    public override func setUpWithError() throws {
        try super.setUpWithError()
        typeDefinition = try XCTUnwrap(assembly.findDefinedType(fullName: "Fields"))
        publicInstanceField = try XCTUnwrap(typeDefinition.findField(name: "PublicInstance"))
        privateStaticInitOnlyField = try XCTUnwrap(typeDefinition.findField(name: "PrivateStaticInitOnly"))
        protectedLiteralField = try XCTUnwrap(typeDefinition.findField(name: "ProtectedLiteral"))
    }

    public func testEnumeration() throws {
        XCTAssertEqual(
            typeDefinition.fields.map { $0.name },
            ["PublicInstance", "PrivateStaticInitOnly", "ProtectedLiteral"])
    }

    public func testName() throws {
        XCTAssertEqual(publicInstanceField.name, "PublicInstance")
    }

    public func testType() throws {
        try XCTAssertEqual(
            XCTUnwrap(publicInstanceField.type.asDefinition),
            XCTUnwrap(assembly.findDefinedType(fullName: "FieldType")))
    }

    public func testVisibility() throws {
        XCTAssertEqual(publicInstanceField.visibility, .public)
        XCTAssertEqual(privateStaticInitOnlyField.visibility, .private)
        XCTAssertEqual(protectedLiteralField.visibility, .family)
    }

    public func testStatic() throws {
        XCTAssertEqual(publicInstanceField.isStatic, false)
        XCTAssertEqual(privateStaticInitOnlyField.isStatic, true)
    }

    public func testInitOnly() throws {
        XCTAssertEqual(publicInstanceField.isInitOnly, false)
        XCTAssertEqual(privateStaticInitOnlyField.isInitOnly, true)
        XCTAssertEqual(protectedLiteralField.isInitOnly, false)
    }

    public func testLiteral() throws {
        XCTAssertEqual(publicInstanceField.isLiteral, false)
        XCTAssertEqual(try publicInstanceField.literalValue, nil)

        XCTAssertEqual(protectedLiteralField.isLiteral, true)
        XCTAssertEqual(try protectedLiteralField.literalValue, Constant.int32(42))
    }
}
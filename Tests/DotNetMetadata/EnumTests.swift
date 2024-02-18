@testable import DotNetMetadata
import XCTest

internal final class EnumTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        enum MyEnum { A = 1, B = 2 }
        [System.Flags] enum MyFlagsEnum { None = 0, A = 1 }
        enum MyShortEnum: short { A = 42 }
        """
    }


    public func testEnumerantNames() throws {
        let enumDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "MyEnum") as? EnumDefinition)
        XCTAssertEqual(enumDefinition.fields.filter { $0.isStatic }.map { $0.name }.sorted(), ["A", "B"])
    }

    public func testUnderlyingType() throws {
        XCTAssertEqual(
            try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "MyEnum") as? EnumDefinition).underlyingType.fullName,
            "System.Int32")
        XCTAssertEqual(
            try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "MyShortEnum") as? EnumDefinition).underlyingType.fullName,
            "System.Int16")
    }

    public func testEnumerantValues() throws {
        let enumDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "MyEnum") as? EnumDefinition)
        XCTAssertEqual(try XCTUnwrap(XCTUnwrap(enumDefinition.findField(name: "A")).literalValue), .int32(1))
        XCTAssertEqual(try XCTUnwrap(XCTUnwrap(enumDefinition.findField(name: "B")).literalValue), .int32(2))

        let shortEnumDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "MyShortEnum") as? EnumDefinition)
        XCTAssertEqual(try XCTUnwrap(XCTUnwrap(shortEnumDefinition.findField(name: "A")).literalValue), .int16(42))
    }

    public func testIsFlags() throws {
        XCTAssertFalse(try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "MyEnum") as? EnumDefinition).isFlags)
        XCTAssertTrue(try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "MyFlagsEnum") as? EnumDefinition).isFlags)
    }
}
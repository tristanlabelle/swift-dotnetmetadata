import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    func testTypeName_topLevelNamespace() throws {
        let object = try XCTUnwrap(Self.assembly.findDefinedType(fullName: "System.Object"))
        XCTAssertEqual(object.name, "Object")
        XCTAssertEqual(object.namespace, "System")
        XCTAssertEqual(object.fullName, "System.Object")
    }

    func testTypeName_nestedNamespace() throws {
        let bitArray = try XCTUnwrap(Self.assembly.findDefinedType(fullName: "System.Collections.BitArray"))
        XCTAssertEqual(bitArray.name, "BitArray")
        XCTAssertEqual(bitArray.namespace, "System.Collections")
        XCTAssertEqual(bitArray.fullName, "System.Collections.BitArray")
    }

    func testTypeName_nested() throws {
        let environment_SpecialFolder = try XCTUnwrap(Self.assembly.findDefinedType(fullName: "System.Environment/SpecialFolder"))
        XCTAssertEqual(environment_SpecialFolder.name, "SpecialFolder")
        XCTAssertEqual(environment_SpecialFolder.namespace, nil)
        XCTAssertEqual(environment_SpecialFolder.fullName, "System.Environment/SpecialFolder")
    }

    func testTypeLayout() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.Object")?.layout,
            TypeLayout.auto)

        // Rare public type with non-zero size
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.ValueTuple")?.layout,
            TypeLayout.sequential(pack: nil, minSize: 1))

        // Rare public type with explicit layout
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.Runtime.InteropServices.BINDPTR")?.layout,
            TypeLayout.explicit(minSize: 0))
    }

    func testEnclosingType() throws {
        XCTAssertIdentical(
            try Self.assembly.findDefinedType(fullName: "System.Environment/SpecialFolder")?.enclosingType,
            Self.assembly.findDefinedType(fullName: "System.Environment"))

        XCTAssertNil(try Self.assembly.findDefinedType(fullName: "System.Environment")?.enclosingType)
    }

    func testBaseType() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.ValueType")?.base?.definition.fullName,
            "System.Object")
    }

    func testBaseInterfaces() throws {
        guard let equalityComparer = Self.assembly.findDefinedType(fullName: "System.Collections.Generic.EqualityComparer`1") else {
            return XCTFail("IAsyncAction not found")
        }
        XCTAssertEqual(
            try equalityComparer.baseInterfaces.map { try $0.interface.definition.fullName }.sorted(),
            [ "System.Collections.Generic.IEqualityComparer`1", "System.Collections.IEqualityComparer" ])
    }

    func testTypeVisibility() throws {
        XCTAssertEqual(Self.assembly.findDefinedType(fullName: "System.Type")?.visibility, .public)
        XCTAssertEqual(Self.assembly.findDefinedType(fullName: "System.RuntimeType")?.visibility, .assembly)
    }

    func testTypeFlags() throws {
        let object = try XCTUnwrap(Self.assembly.findDefinedType(fullName: "System.Object"))
        XCTAssert(!object.isAbstract)
        XCTAssert(!object.isSealed)

        let gc = try XCTUnwrap(Self.assembly.findDefinedType(fullName: "System.GC"))
        XCTAssert(gc.isAbstract)
        XCTAssert(gc.isSealed)
    }

    func testTypeDefinitionClass() throws {
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "System.Int32") as? StructDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "System.IDisposable") as? InterfaceDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "System.String") as? ClassDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "System.StringComparison") as? EnumDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "System.Action") as? DelegateDefinition)
    }

    func testTypeGenericParamEnumeration() throws {
        // Interface with 1 generic parameter
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.Action`1")?.genericParams.map({ $0.name }),
            [ "T" ])

        // Delegate with 2 generic parameters
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.Action`2")?.genericParams.map({ $0.name }),
            [ "T1", "T2" ])
    }

    func testEnum() throws {
        guard let dayOfWeek = Self.assembly.findDefinedType(fullName: "System.DayOfWeek") as? EnumDefinition else {
            return XCTFail("System.DayOfWeek not found")
        }

        XCTAssertEqual(try dayOfWeek.underlyingType.fullName, "System.Int32")
        XCTAssertEqual(try dayOfWeek.findField(name: "Sunday")?.literalValue, Constant.int32(0))
        XCTAssertEqual(try dayOfWeek.findField(name: "Thursday")?.literalValue, Constant.int32(4))
    }

    func testNestedType() throws {
         XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.Collections.Generic.List`1")?.nestedTypes.contains { $0.name == "Enumerator" },
            true)
    }
}

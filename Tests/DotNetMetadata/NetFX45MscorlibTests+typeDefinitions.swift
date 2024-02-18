import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    func testTypeName_topLevelNamespace() throws {
        let object = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.Object"))
        XCTAssertEqual(object.name, "Object")
        XCTAssertEqual(object.namespace, "System")
        XCTAssertEqual(object.fullName, "System.Object")
    }

    func testTypeName_nestedNamespace() throws {
        let bitArray = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.Collections.BitArray"))
        XCTAssertEqual(bitArray.name, "BitArray")
        XCTAssertEqual(bitArray.namespace, "System.Collections")
        XCTAssertEqual(bitArray.fullName, "System.Collections.BitArray")
    }

    func testTypeName_nested() throws {
        let environment_SpecialFolder = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.Environment/SpecialFolder"))
        XCTAssertEqual(environment_SpecialFolder.name, "SpecialFolder")
        XCTAssertEqual(environment_SpecialFolder.namespace, nil)
        XCTAssertEqual(environment_SpecialFolder.fullName, "System.Environment/SpecialFolder")
    }

    func testTypeLayout() throws {
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Object")?.layout,
            TypeLayout.auto)

        // Rare public type with non-zero size
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.ValueTuple")?.layout,
            TypeLayout.sequential(pack: nil, minSize: 1))

        // Rare public type with explicit layout
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Runtime.InteropServices.BINDPTR")?.layout,
            TypeLayout.explicit(minSize: 0))
    }

    func testEnclosingType() throws {
        XCTAssertIdentical(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Environment/SpecialFolder")?.enclosingType,
            try Self.assembly.resolveTypeDefinition(fullName: "System.Environment"))

        XCTAssertNil(try Self.assembly.resolveTypeDefinition(fullName: "System.Environment")?.enclosingType)
    }

    func testBaseType() throws {
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.ValueType")?.base?.definition.fullName,
            "System.Object")
    }

    func testBaseInterfaces() throws {
        guard let equalityComparer = try Self.assembly.resolveTypeDefinition(fullName: "System.Collections.Generic.EqualityComparer`1") else {
            return XCTFail("IAsyncAction not found")
        }
        XCTAssertEqual(
            try equalityComparer.baseInterfaces.map { try $0.interface.definition.fullName }.sorted(),
            [ "System.Collections.Generic.IEqualityComparer`1", "System.Collections.IEqualityComparer" ])
    }

    func testTypeVisibility() throws {
        XCTAssertEqual(try Self.assembly.resolveTypeDefinition(fullName: "System.Type")?.visibility, .public)
        XCTAssertEqual(try Self.assembly.resolveTypeDefinition(fullName: "System.RuntimeType")?.visibility, .assembly)
    }

    func testTypeFlags() throws {
        let object = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.Object") as? ClassDefinition)
        XCTAssert(!object.isAbstract)
        XCTAssert(!object.isSealed)

        let gc = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.GC") as? ClassDefinition)
        XCTAssert(gc.isAbstract)
        XCTAssert(gc.isSealed)
    }

    func testTypeDefinitionClass() throws {
        XCTAssertNotNil(try Self.assembly.resolveTypeDefinition(fullName: "System.Int32") as? StructDefinition)
        XCTAssertNotNil(try Self.assembly.resolveTypeDefinition(fullName: "System.IDisposable") as? InterfaceDefinition)
        XCTAssertNotNil(try Self.assembly.resolveTypeDefinition(fullName: "System.String") as? ClassDefinition)
        XCTAssertNotNil(try Self.assembly.resolveTypeDefinition(fullName: "System.StringComparison") as? EnumDefinition)
        XCTAssertNotNil(try Self.assembly.resolveTypeDefinition(fullName: "System.Action") as? DelegateDefinition)
    }

    func testTypeGenericParamEnumeration() throws {
        // Interface with 1 generic parameter
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Action`1")?.genericParams.map({ $0.name }),
            [ "T" ])

        // Delegate with 2 generic parameters
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Action`2")?.genericParams.map({ $0.name }),
            [ "T1", "T2" ])
    }

    func testNestedType() throws {
         XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Collections.Generic.List`1")?.nestedTypes.contains { $0.name == "Enumerator" },
            true)
    }
}

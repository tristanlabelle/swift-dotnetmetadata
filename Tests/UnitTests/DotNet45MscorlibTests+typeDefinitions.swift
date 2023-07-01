import Foundation
import XCTest
@testable import DotNetMD

extension DotNet45MscorlibTests {
    func testTypeName_topLevelNamespace() throws {
        let object = Self.assembly.findDefinedType(fullName: "System.Object")
        XCTAssertEqual(object?.name, "Object")
        XCTAssertEqual(object?.namespace, "System")
        XCTAssertEqual(object?.fullName, "System.Object")
    }

    func testTypeName_nestedNamespace() throws {
        let bitArray = Self.assembly.findDefinedType(fullName: "System.Collections.BitArray")
        XCTAssertEqual(bitArray?.name, "BitArray")
        XCTAssertEqual(bitArray?.namespace, "System.Collections")
        XCTAssertEqual(bitArray?.fullName, "System.Collections.BitArray")
    }

    func testTypeName_nested() throws {
        let environment_SpecialFolder = Self.assembly.findDefinedType(fullName: "System.Environment/SpecialFolder")
        XCTAssertEqual(environment_SpecialFolder?.name, "SpecialFolder")
        XCTAssertEqual(environment_SpecialFolder?.namespace, nil)
        XCTAssertEqual(environment_SpecialFolder?.fullName, "System.Environment/SpecialFolder")
    }

    func testEnclosingType() throws {
        XCTAssertIdentical(
            Self.assembly.findDefinedType(fullName: "System.Environment/SpecialFolder")?.enclosingType,
            Self.assembly.findDefinedType(fullName: "System.Environment"))

        XCTAssertNil(Self.assembly.findDefinedType(fullName: "System.Environment")?.enclosingType)
    }

    func testBaseType() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.ValueType")?.unboundBase?.fullName,
            "System.Object")
    }

    func testBaseInterfaces() throws {
        guard let equalityComparer = Self.assembly.findDefinedType(fullName: "System.Collections.Generic.EqualityComparer`1") else {
            XCTFail("IAsyncAction not found")
            return
        }
        XCTAssertEqual(
            equalityComparer.baseInterfaces.map { $0.unboundInterface?.fullName ?? "" }.sorted(),
            [ "System.Collections.Generic.IEqualityComparer`1", "System.Collections.IEqualityComparer" ])
    }

    func testTypeVisibility() throws {
        XCTAssertEqual(Self.assembly.findDefinedType(fullName: "System.Type")?.visibility, .public)
        XCTAssertEqual(Self.assembly.findDefinedType(fullName: "System.RuntimeType")?.visibility, .assembly)
    }

    func testTypeFlags() throws {
        let object = Self.assembly.findDefinedType(fullName: "System.Object")
        XCTAssert(object?.isAbstract == false)
        XCTAssert(object?.isSealed == false)

        let gc = Self.assembly.findDefinedType(fullName: "System.GC")
        XCTAssert(gc?.isAbstract == true)
        XCTAssert(gc?.isSealed == true)
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
            XCTFail("System.DayOfWeek not found")
            return
        }

        try XCTAssertEqual(dayOfWeek.underlyingType.fullName, "System.Int32")
        try XCTAssertEqual(dayOfWeek.findField(name: "Sunday")?.literalValue, Constant.int32(0))
        try XCTAssertEqual(dayOfWeek.findField(name: "Thursday")?.literalValue, Constant.int32(4))
    }
}

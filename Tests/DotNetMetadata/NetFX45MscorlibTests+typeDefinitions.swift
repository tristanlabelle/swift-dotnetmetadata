import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
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
}

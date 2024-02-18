import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    func testTypeMethodEnumeration() throws {
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Collections.Generic.IEqualityComparer`1")?.methods.map({ $0.name }).sorted(),
            [ "Equals", "GetHashCode" ])
    }

    func testMethodClass() throws {
        let object = try Self.assembly.resolveTypeDefinition(fullName: "System.Object")
        XCTAssertNil(object?.findMethod(name: "ToString") as? Constructor)
        XCTAssertNotNil(object?.findMethod(name: Constructor.name) as? Constructor)
    }

    func testMethodFlags() throws {
        // Abstract interface method
        let iasyncResult_get_IsCompleted = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.IAsyncResult")?
            .findMethod(name: "get_IsCompleted"))
        XCTAssertEqual(iasyncResult_get_IsCompleted.isStatic, false)
        XCTAssertEqual(iasyncResult_get_IsCompleted.isInstance, true)
        XCTAssertEqual(iasyncResult_get_IsCompleted.isVirtual, true)
        XCTAssertEqual(iasyncResult_get_IsCompleted.isAbstract, true)
        XCTAssertEqual(iasyncResult_get_IsCompleted.nameKind, NameKind.special)

        // Static method
        let gc_WaitForPendingFinalizers = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.GC")?
            .findMethod(name: "WaitForPendingFinalizers"))
        XCTAssertEqual(gc_WaitForPendingFinalizers.isStatic, true)
        XCTAssertEqual(gc_WaitForPendingFinalizers.isInstance, false)
        XCTAssertEqual(gc_WaitForPendingFinalizers.isVirtual, false)
        XCTAssertEqual(gc_WaitForPendingFinalizers.isAbstract, false)
        XCTAssertEqual(gc_WaitForPendingFinalizers.nameKind, NameKind.regular)

        // Overriden virtual method
        let exception_ToString = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.Exception")?
            .findMethod(name: "ToString", public: true, arity: 0))
        XCTAssertEqual(exception_ToString.isStatic, false)
        XCTAssertEqual(exception_ToString.isInstance, true)
        XCTAssertEqual(exception_ToString.isVirtual, true)
        XCTAssertEqual(exception_ToString.isNewSlot, false)
        XCTAssertEqual(exception_ToString.isOverride, true)
    }

    func testMethodParamEnumeration() throws {
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Object")?
                .findMethod(name: "ReferenceEquals")?.params.map { $0.name },
            [ "objA", "objB" ])

        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Object")?
                .findMethod(name: "ToString")?.params.count, 0)
    }

    func testMethodHasReturnValue() throws {
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Object")?
                .findMethod(name: "ToString")?.hasReturnValue,
            true)

        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.IDisposable")?
                .findMethod(name: "Dispose")?.hasReturnValue,
            false)
    }

    func testMethodReturnType() throws {
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Object")?
                .findMethod(name: "ToString")?.returnType.asDefinition?.fullName,
            "System.String")

        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.IDisposable")?
                .findMethod(name: "Dispose")?.returnType.asDefinition?.fullName,
            "System.Void")
    }

    func testMethodParamType() throws {
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.String")?
                .findMethod(name: "IsNullOrEmpty")?.params[0].type.asDefinition?.fullName,
            "System.String")
    }

    func testParamByRef() throws {
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Guid")?
                .findMethod(name: "TryParse")?.params.map { $0.isByRef },
            [ false, true ])
    }

    func testOverloadBinding() throws {
        guard let convert = try Self.assembly.resolveTypeDefinition(fullName: "System.Convert") else {
            return XCTFail("Failed to find System.Convert")
        }

        guard let toBooleanByte = convert.findMethod(name: "ToBoolean", paramTypes: [ try coreLibrary.systemByte.bindNode() ]),
            let toBooleanString = convert.findMethod(name: "ToBoolean", paramTypes: [ try coreLibrary.systemString.bindNode() ]) else {
            return XCTFail("Failed to find System.Convert.ToBoolean overloads")
        }

        XCTAssertNotIdentical(toBooleanByte, toBooleanString)
    }
}

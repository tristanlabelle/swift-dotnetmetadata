import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    func testTypeMethodEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.Collections.Generic.IEqualityComparer`1")?.methods.map({ $0.name }).sorted(),
            [ "Equals", "GetHashCode" ])
    }

    func testMethodClass() throws {
        let object = Self.assembly.findDefinedType(fullName: "System.Object")
        XCTAssertNil(object?.findSingleMethod(name: "ToString") as? Constructor)
        XCTAssertNotNil(object?.findSingleMethod(name: ".ctor") as? Constructor)
    }

    func testMethodFlags() throws {
        let iasyncResult_get_IsCompleted = Self.assembly.findDefinedType(fullName: "System.IAsyncResult")?
            .findSingleMethod(name: "get_IsCompleted")
        XCTAssertEqual(iasyncResult_get_IsCompleted?.isStatic, false)
        XCTAssertEqual(iasyncResult_get_IsCompleted?.isVirtual, true)
        XCTAssertEqual(iasyncResult_get_IsCompleted?.isAbstract, true)
        XCTAssertEqual(iasyncResult_get_IsCompleted?.isSpecialName, true)

        let gc_WaitForPendingFinalizers = Self.assembly.findDefinedType(fullName: "System.GC")?
            .findSingleMethod(name: "WaitForPendingFinalizers")
        XCTAssertEqual(gc_WaitForPendingFinalizers?.isStatic, true)
        XCTAssertEqual(gc_WaitForPendingFinalizers?.isVirtual, false)
        XCTAssertEqual(gc_WaitForPendingFinalizers?.isAbstract, false)
        XCTAssertEqual(gc_WaitForPendingFinalizers?.isSpecialName, false)
    }

    func testMethodParamEnumeration() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.Object")?
                .findSingleMethod(name: "ReferenceEquals")?.params.map { $0.name },
            [ "objA", "objB" ])

        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.Object")?
                .findSingleMethod(name: "ToString")?.params.count, 0)
    }

    func testMethodHasReturnValue() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.Object")?
                .findSingleMethod(name: "ToString")?.hasReturnValue,
            true)

        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.IDisposable")?
                .findSingleMethod(name: "Dispose")?.hasReturnValue,
            false)
    }

    func testMethodReturnType() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.Object")?
                .findSingleMethod(name: "ToString")?.returnType.asDefinition?.fullName,
            "System.String")

        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.IDisposable")?
                .findSingleMethod(name: "Dispose")?.returnType.asDefinition?.fullName,
            "System.Void")
    }

    func testMethodParamType() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.String")?
                .findSingleMethod(name: "IsNullOrEmpty")?.params[0].type.asDefinition?.fullName,
            "System.String")
    }

    func testParamByRef() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.Guid")?
                .findSingleMethod(name: "TryParse")?.params.map { $0.isByRef },
            [ false, true ])
    }
}

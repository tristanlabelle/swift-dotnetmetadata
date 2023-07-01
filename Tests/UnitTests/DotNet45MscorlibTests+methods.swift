import Foundation
import XCTest
@testable import DotNetMD

extension DotNet45MscorlibTests {
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
        try XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.Object")?
                .findSingleMethod(name: "ReferenceEquals")?.params.map { $0.name },
            [ "objA", "objB" ])

        try XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.Object")?
                .findSingleMethod(name: "ToString")?.params.count, 0)
    }
    
    func testMethodReturnType() throws {
        try XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.Object")?
                .findSingleMethod(name: "ToString")?.returnType.asUnbound?.fullName,
            "System.String")

        try XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.IDisposable")?
                .findSingleMethod(name: "Dispose")?.returnType.asUnbound?.fullName,
            "System.Void")
    }

    func testMethodParamType() throws {
        try XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.String")?
                .findSingleMethod(name: "IsNullOrEmpty")?.params[0].type.asUnbound?.fullName,
            "System.String")
    }

    func testParamByRef() throws {
        try XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.Guid")?
                .findSingleMethod(name: "TryParse")?.params.map { $0.isByRef },
            [ false, true ])
    }
}

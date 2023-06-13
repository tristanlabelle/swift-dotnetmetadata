import Foundation
import XCTest
@testable import DotNetMDLogical

extension WindowsWinMDTests {
    func testTypeMethodEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncInfo")?.methods.map({ $0.name }).sorted(),
            [ "Cancel", "Close", "get_ErrorCode", "get_Id", "get_Status" ])
    }

    func testMethodClass() throws {
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.MemoryBuffer")?
            .findSingleMethod(name: ".ctor") as? Constructor)
    }

    func testMethodFlags() throws {
        let iasyncInfo_get_Id = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncInfo")?
            .findSingleMethod(name: "get_Id")
        XCTAssertEqual(iasyncInfo_get_Id?.isStatic, false)
        XCTAssertEqual(iasyncInfo_get_Id?.isVirtual, true)
        XCTAssertEqual(iasyncInfo_get_Id?.isAbstract, true)
        XCTAssertEqual(iasyncInfo_get_Id?.isSpecialName, true)

        let guidHelper_createNewGuid = Self.assembly.findDefinedType(fullName: "Windows.Foundation.GuidHelper")?
            .findSingleMethod(name: "CreateNewGuid")
        XCTAssertEqual(guidHelper_createNewGuid?.isStatic, true)
        XCTAssertEqual(guidHelper_createNewGuid?.isVirtual, false)
        XCTAssertEqual(guidHelper_createNewGuid?.isAbstract, false)
        XCTAssertEqual(guidHelper_createNewGuid?.isSpecialName, false)
    }

    func testMethodParamEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.AsyncActionCompletedHandler")?
                .findSingleMethod(name: "Invoke")?.params.map { $0.name },
            ["asyncInfo", "asyncStatus"])

        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IClosable")?
                .findSingleMethod(name: "Close")?.params.count, 0)
    }
    
    func testMethodReturnType() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IPropertyValue")?
                .findSingleMethod(name: "GetChar16")?.returnType.asUnbound?.fullName,
            "System.Char")

        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IClosable")?
                .findSingleMethod(name: "Close")?.returnType.asUnbound?.fullName,
            "System.Void")
    }

    func testMethodParamType() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.PropertyValue")?
                .findSingleMethod(name: "CreateUInt16")?.params[0].type.asUnbound?.fullName,
            "System.UInt16")
    }
}

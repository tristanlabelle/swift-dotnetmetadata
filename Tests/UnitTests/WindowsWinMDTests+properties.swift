import Foundation
import XCTest
@testable import DotNetMD

extension WindowsWinMDTests {
    func testTypePropertyEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncInfo")?.properties.map({ $0.name }).sorted(),
            [ "ErrorCode", "Id", "Status" ])
    }

    func testPropertyType() throws {
        try XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Uri")?
                .findProperty(name: "Domain")?.type.asUnbound?.fullName,
            "System.String")
    }

    func testPropertyAccessors() throws {
        let iasyncAction_Completed = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncAction")?
                .findProperty(name: "Completed")
        try XCTAssertNotNil(iasyncAction_Completed?.getter)
        try XCTAssertNotNil(iasyncAction_Completed?.setter)
        
        let iasyncInfo_Status = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncInfo")?
                .findProperty(name: "Status")
        try XCTAssertNotNil(iasyncInfo_Status?.getter)
        try XCTAssertNil(iasyncInfo_Status?.setter)
    }
}

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
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Uri")?
                .findProperty(name: "Domain")?.type.asUnbound?.fullName,
            "System.String")
    }

    func testPropertyAccessors() throws {
        let iasyncAction_Completed = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncAction")?
                .findProperty(name: "Completed")
        XCTAssertNotNil(iasyncAction_Completed?.getter)
        XCTAssertNotNil(iasyncAction_Completed?.setter)
        
        let iasyncInfo_Status = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncInfo")?
                .findProperty(name: "Status")
        XCTAssertNotNil(iasyncInfo_Status?.getter)
        XCTAssertNil(iasyncInfo_Status?.setter)
    }
}

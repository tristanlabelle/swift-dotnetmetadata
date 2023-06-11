import Foundation
import XCTest
@testable import DotNetMDLogical

extension WindowsWinMDTests {
    func testTypeGenericParamEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Collections.IKeyValuePair`2")?.genericParams.map({ $0.name }).sorted(),
            [ "K", "V" ])
    }

    func testTypeMethodEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncInfo")?.methods.map({ $0.name }).sorted(),
            [ "Cancel", "Close", "get_ErrorCode", "get_Id", "get_Status" ])
    }

    func testTypeFieldEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point")?.fields.map({ $0.name }).sorted(),
            [ "X", "Y" ])
    }

    func testTypePropertyEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncInfo")?.properties.map({ $0.name }).sorted(),
            [ "ErrorCode", "Id", "Status" ])
    }

    func testTypeEventEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Devices.Enumeration.DeviceWatcher")?.events.map({ $0.name }).sorted(),
            [ "Added", "EnumerationCompleted", "Removed", "Stopped", "Updated" ])
    }
}

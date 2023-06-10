import XCTest
@testable import WinMDGraph

extension WindowsWinMDTests {
    func testGenericTypeParamEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.Collections.IKeyValuePair`2")?.genericParams.map({ $0.name }).sorted(),
            [ "K", "V" ])
    }

    func testMethodEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IAsyncInfo")?.methods.map({ $0.name }).sorted(),
            [ "Cancel", "Close", "get_ErrorCode", "get_Id", "get_Status" ])
    }

    func testFieldEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.Point")?.fields.map({ $0.name }).sorted(),
            [ "X", "Y" ])
    }

    func testPropertyEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IAsyncInfo")?.properties.map({ $0.name }).sorted(),
            [ "ErrorCode", "Id", "Status" ])
    }

    func testEventEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Devices.Enumeration.DeviceWatcher")?.events.map({ $0.name }).sorted(),
            [ "Added", "EnumerationCompleted", "Removed", "Stopped", "Updated" ])
    }
}

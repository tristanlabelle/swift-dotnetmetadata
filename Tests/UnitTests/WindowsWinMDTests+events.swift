import Foundation
import XCTest
@testable import DotNetMD

extension WindowsWinMDTests {
    func testTypeEventEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Devices.Enumeration.DeviceWatcher")?.events.map({ $0.name }).sorted(),
            [ "Added", "EnumerationCompleted", "Removed", "Stopped", "Updated" ])
    }
}

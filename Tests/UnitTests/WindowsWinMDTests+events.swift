import Foundation
import XCTest
@testable import DotNetMD

extension WindowsWinMDTests {
    func testTypeEventEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Devices.Enumeration.DeviceWatcher")?.events.map({ $0.name }).sorted(),
            [ "Added", "EnumerationCompleted", "Removed", "Stopped", "Updated" ])
    }

    func testEventType() throws {
        guard let loggingChannel = Self.assembly.findDefinedType(fullName: "Windows.Foundation.Diagnostics.ILoggingChannel") else {
            XCTFail("Could not find ILoggingChannel")
            return
        }

        guard let typedEventHandler = Self.assembly.findDefinedType(fullName: "Windows.Foundation.TypedEventHandler`2") else {
            XCTFail("Could not find TypedEventHandler")
            return
        }

        XCTAssertEqual(
            loggingChannel.findEvent(name: "LoggingEnabled")?.type,
            typedEventHandler.bind(genericArgs: [
                loggingChannel.bindNonGeneric(),
                Self.context.mscorlib!.specialTypes.object.bindNonGeneric()
            ]))
    }
}

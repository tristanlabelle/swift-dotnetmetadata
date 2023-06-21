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
        guard let imemoryBufferReference = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IMemoryBufferReference") else {
            XCTFail("Could not find IMemoryBufferReference")
            return
        }

        guard let typedEventHandler = Self.assembly.findDefinedType(fullName: "Windows.Foundation.TypedEventHandler`2") else {
            XCTFail("Could not find TypedEventHandler")
            return
        }

        try XCTAssertEqual(
            imemoryBufferReference.findEvent(name: "Closed")?.type,
            typedEventHandler.bind(genericArgs: [
                imemoryBufferReference.bindNonGeneric(),
                Self.context.mscorlib!.specialTypes.object.bindNonGeneric()
            ]))
    }
}

import Foundation
import XCTest
@testable import DotNetMD

extension NetFX45MscorlibTests {
    func testTypeEventEnumeration() throws {
        try XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.Diagnostics.Tracing.EventListener")?.events
                .filter({ try $0.visibility == .public }).map({ $0.name }).sorted(),
            [ "EventSourceCreated", "EventWritten" ])
    }

    func testEventAccessors() throws {
        guard let event = Self.assembly.findDefinedType(fullName: "System.Diagnostics.Tracing.EventListener")?.findEvent(name: "EventSourceCreated") else {
            XCTFail("Could not find System.Diagnostics.Tracing.EventListener.EventSourceCreated")
            return
        }

        XCTAssertEqual(try event.addAccessor?.name, "add_EventSourceCreated")
        XCTAssertEqual(try event.removeAccessor?.name, "remove_EventSourceCreated")
    }

    func testEventType() throws {
        guard let console = Self.assembly.findDefinedType(fullName: "System.Console") else {
            XCTFail("Could not find System.Console")
            return
        }

        guard let consoleCancelEventHandler = Self.assembly.findDefinedType(fullName: "System.ConsoleCancelEventHandler") else {
            XCTFail("Could not find System.ConsoleCancelEventHandler")
            return
        }

        XCTAssertEqual(
            try console.findEvent(name: "CancelKeyPress")?.handlerType,
            consoleCancelEventHandler.bindNonGeneric())
    }
}

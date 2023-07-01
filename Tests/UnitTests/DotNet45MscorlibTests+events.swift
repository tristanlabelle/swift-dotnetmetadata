import Foundation
import XCTest
@testable import DotNetMD

extension DotNet45MscorlibTests {
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

        try XCTAssertEqual(event.addAccessor?.name, "add_EventSourceCreated")
        try XCTAssertEqual(event.removeAccessor?.name, "remove_EventSourceCreated")
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

        try XCTAssertEqual(
            console.findEvent(name: "CancelKeyPress")?.handlerType,
            consoleCancelEventHandler.bindNonGeneric())
    }
}

import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    func testTypeEventEnumeration() throws {
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Diagnostics.Tracing.EventListener")?.events
                .filter({ $0.hasPublicAddRemoveAccessors }).map({ $0.name }).sorted(),
            [ "EventSourceCreated", "EventWritten" ])
    }

    func testEventAccessors() throws {
        let event = try XCTUnwrap(
            Self.assembly.resolveTypeDefinition(fullName: "System.Diagnostics.Tracing.EventListener")?
                .findEvent(name: "EventSourceCreated"))

        XCTAssertEqual(try XCTUnwrap(event.addAccessor).name, "add_EventSourceCreated")
        XCTAssertEqual(try XCTUnwrap(event.removeAccessor).name, "remove_EventSourceCreated")
    }

    func testEventType() throws {
        let console = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.Console"))
        let consoleCancelEventHandler = try XCTUnwrap(
            Self.assembly.resolveTypeDefinition(fullName: "System.ConsoleCancelEventHandler") as? DelegateDefinition)

        XCTAssertEqual(
            try XCTUnwrap(console.findEvent(name: "CancelKeyPress")).handlerType,
            consoleCancelEventHandler.bind())
    }
}

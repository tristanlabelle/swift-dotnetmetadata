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

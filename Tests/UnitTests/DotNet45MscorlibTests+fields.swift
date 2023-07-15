import Foundation
import XCTest
@testable import DotNetMD

extension DotNet45MscorlibTests {
    func testTypeFieldEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.ValueTuple`2")?.fields.map({ $0.name }).sorted(),
            [ "Item1", "Item2" ])
    }

    func testFieldType() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.Nullable`1")?
                .findField(name: "hasValue")?.type.asUnbound?.fullName,
            "System.Boolean")
    }
}

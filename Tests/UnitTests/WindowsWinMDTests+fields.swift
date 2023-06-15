import Foundation
import XCTest
@testable import DotNetMD

extension WindowsWinMDTests {
    func testTypeFieldEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point")?.fields.map({ $0.name }).sorted(),
            [ "X", "Y" ])
    }

    func testFieldType() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point")?
                .findField(name: "X")?.type.asUnbound?.fullName,
            "System.Single")
    }
}

import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    func testEnumIsFlags() throws {
        XCTAssertEqual((Self.assembly.findDefinedType(fullName: "System.StringComparison") as? EnumDefinition)?.isFlags, false)
        XCTAssertEqual((Self.assembly.findDefinedType(fullName: "System.StringSplitOptions") as? EnumDefinition)?.isFlags, true)
    }
}

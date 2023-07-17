import Foundation
import XCTest
@testable import DotNetMD

extension NetFX45MscorlibTests {
    func testTypeAttributes() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.IDisposable")?.attributes
                .contains { try $0.type.fullName == "System.Runtime.InteropServices.ComVisibleAttribute" },
            true)
    }
}

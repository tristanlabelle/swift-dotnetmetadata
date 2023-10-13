import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    func testFieldType() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.Nullable`1")?
                .findField(name: "hasValue")?.type.asDefinition?.fullName,
            "System.Boolean")
    }
}

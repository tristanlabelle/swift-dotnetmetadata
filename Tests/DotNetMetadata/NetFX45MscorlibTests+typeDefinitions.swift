import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    func testTypeGenericParamEnumeration() throws {
        // Interface with 1 generic parameter
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Action`1")?.genericParams.map({ $0.name }),
            [ "T" ])

        // Delegate with 2 generic parameters
        XCTAssertEqual(
            try Self.assembly.resolveTypeDefinition(fullName: "System.Action`2")?.genericParams.map({ $0.name }),
            [ "T1", "T2" ])
    }
}

import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    func testAttribute() throws {
        guard let comVisibleAttribute = try Self.assembly.findDefinedType(fullName: "System.IDisposable")?.attributes
            .first(where: { try $0.type.fullName == "System.Runtime.InteropServices.ComVisibleAttribute" })
        else { return XCTFail("Missing attribute") }

        XCTAssertEqual(try comVisibleAttribute.arguments, [ .constant(.boolean(true)) ])
        XCTAssertEqual(try comVisibleAttribute.namedArguments, [])
    }

    func testEnumIsFlags() throws {
        XCTAssertEqual((Self.assembly.findDefinedType(fullName: "System.StringComparison") as? EnumDefinition)?.isFlags, false)
        XCTAssertEqual((Self.assembly.findDefinedType(fullName: "System.StringSplitOptions") as? EnumDefinition)?.isFlags, true)
    }
}

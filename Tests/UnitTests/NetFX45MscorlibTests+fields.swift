import Foundation
import XCTest
@testable import DotNetMD

extension NetFX45MscorlibTests {
    func testTypeFieldEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.ValueTuple`2")?.fields.map({ $0.name }).sorted(),
            [ "Item1", "Item2" ])
    }

    func testFieldType() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "System.Nullable`1")?
                .findField(name: "hasValue")?.type.asDefinition?.fullName,
            "System.Boolean")
    }

    func testFieldExplicitOffset() throws {
        // Default case with nil explicit offset
        guard let int32_MaxValue = Self.assembly.findDefinedType(fullName: "System.Int32")?.findField(name: "MaxValue") else {
            return XCTFail("Int32.MaxValue not found")
        }
        XCTAssertNil(int32_MaxValue.explicitOffset)

        // Rare public type with explicit layout (union-like)
        guard let bindPtr = Self.assembly.findDefinedType(fullName: "System.Runtime.InteropServices.BINDPTR") else {
            return XCTFail("BINDPTR not found")
        }

        XCTAssertEqual(bindPtr.findField(name: "lpfuncdesc")?.explicitOffset, 0)
        XCTAssertEqual(bindPtr.findField(name: "lpvardesc")?.explicitOffset, 0)
        XCTAssertEqual(bindPtr.findField(name: "lptcomp")?.explicitOffset, 0)
    }
}

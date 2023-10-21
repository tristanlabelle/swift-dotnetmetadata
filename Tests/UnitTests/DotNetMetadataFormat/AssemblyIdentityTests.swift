import XCTest
@testable import DotNetMetadataFormat

final class AssemblyIdentityTests: XCTestCase {
    func testToString() {
        let value = AssemblyIdentity(
            name: "mscorlib",
            version: .init(major: 2, minor: 0, buildNumber: 0, revisionNumber: 0),
            culture: "neutral",
            publicKey: .token([ 0xb7, 0x7a, 0x5c, 0x56, 0x19, 0x34, 0xe0, 0x89 ]))
        XCTAssertEqual(value.description,
            "mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    }

    func testParse() throws {
        let value = try AssemblyIdentity.parse("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
        XCTAssertEqual(value.name, "mscorlib")
        XCTAssertEqual(value.version, AssemblyVersion(major: 2, minor: 0, buildNumber: 0, revisionNumber: 0))
        XCTAssertEqual(value.culture, "neutral")
        XCTAssertEqual(value.publicKey, .token([ 0xb7, 0x7a, 0x5c, 0x56, 0x19, 0x34, 0xe0, 0x89 ]))
    }
}
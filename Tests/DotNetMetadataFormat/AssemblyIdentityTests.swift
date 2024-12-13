import Testing
@testable import DotNetMetadataFormat

struct AssemblyIdentityTests {
    @Test func testToString() {
        let value = AssemblyIdentity(
            name: "mscorlib",
            version: .init(major: 2, minor: 0, buildNumber: 0, revisionNumber: 0),
            culture: "neutral",
            publicKey: .token([ 0xb7, 0x7a, 0x5c, 0x56, 0x19, 0x34, 0xe0, 0x89 ]))
        #expect(value.description == "mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    }

    @Test func testParse() throws {
        let value = try AssemblyIdentity.parse("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
        #expect(value.name == "mscorlib")
        #expect(value.version == FourPartVersion(major: 2, minor: 0, buildNumber: 0, revisionNumber: 0))
        #expect(value.culture == "neutral")
        #expect(value.publicKey == .token([ 0xb7, 0x7a, 0x5c, 0x56, 0x19, 0x34, 0xe0, 0x89 ]))
    }

    @Test func testParsePublicKey() throws {
        #expect(try AssemblyIdentity.parse("name, PublicKey=1234").publicKey
            == .full([ 0x12, 0x34 ]))

        #expect(try AssemblyIdentity.parse("name, PublicKeyToken=b77a5c561934e089").publicKey
            == .token([ 0xb7, 0x7a, 0x5c, 0x56, 0x19, 0x34, 0xe0, 0x89 ]))

        #expect(try AssemblyIdentity.parse("name").publicKey == nil)
        #expect(try AssemblyIdentity.parse("name, PublicKey=null").publicKey == nil)
        #expect(try AssemblyIdentity.parse("name, PublicKeyToken=null").publicKey == nil)
    }
}
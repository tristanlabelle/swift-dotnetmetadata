@testable import WindowsMetadata
import XCTest

final class SHA1Tests: XCTestCase {
    func toHex(_ bytes: [UInt8]) -> String {
        bytes.map { String(format: "%02x", $0) }.joined()
    }

    func testValueOfEmpty() throws {
        XCTAssertEqual(toHex(SHA1.get([])), "da39a3ee5e6b4b0d3255bfef95601890afd80709")
    }

    func testValueOfSingleByte() throws {
        XCTAssertEqual(toHex(SHA1.get([0x42])), "ae4f281df5a5d0ff3cad6371f76d5c29b6d953ec")
    }

    func testValuesAroundPaddingLength() throws {
        // Pad with 0x80 0x00, then message length
        XCTAssertEqual(
            toHex(SHA1.get([UInt8](repeating: 0x42, count: SHA1.blockSize - 10))),
            "9f577f3425985e9b9ec5b11c4ed76675eb4a2aeb")
        // Pad with 0x80, then message length
        XCTAssertEqual(
            toHex(SHA1.get([UInt8](repeating: 0x42, count: SHA1.blockSize - 9))),
            "f42fc57c149118d6307f96b17acc00f19b4c8de7")
        // Pad with 0x80 + 0x00*64, then message length
        XCTAssertEqual(
            toHex(SHA1.get([UInt8](repeating: 0x42, count: SHA1.blockSize - 8))),
            "021f99328a6a79566f055914466ae1654d16ab01")
    }

    func testValueOfOneBlockPlusOneByte() throws {
        XCTAssertEqual(
            toHex(SHA1.get([UInt8](repeating: 0x42, count: 65))),
            "550fdc7cb0c34885cf8632c33c7057947578142b")
    }

    func testIntraBlockAppending() throws {
        let oneThenOneByte = {
            var sha1 = SHA1()
            sha1.process([0x00])
            sha1.process([0x01])
            return sha1.finalize()
        }()

        let twoBytes = SHA1.get([0x00, 0x01])
        XCTAssertEqual(oneThenOneByte, twoBytes)
    }

    func testBlockSplitting() throws {
        let oneAndAHalfBlock = {
            var sha1 = SHA1()
            sha1.process([UInt8](repeating: 0, count: SHA1.blockSize * 3 / 2))
            return sha1.finalize()
        }()

        let oneThenHalfBlock = {
            var sha1 = SHA1()
            sha1.process([UInt8](repeating: 0, count: SHA1.blockSize))
            sha1.process([UInt8](repeating: 0, count: SHA1.blockSize / 2))
            return sha1.finalize()
        }()

        let halfThenOneBlock = {
            var sha1 = SHA1()
            sha1.process([UInt8](repeating: 0, count: SHA1.blockSize / 2))
            sha1.process([UInt8](repeating: 0, count: SHA1.blockSize))
            return sha1.finalize()
        }()

        XCTAssertEqual(oneAndAHalfBlock, oneThenHalfBlock)
        XCTAssertEqual(oneAndAHalfBlock, halfThenOneBlock)
    }
}

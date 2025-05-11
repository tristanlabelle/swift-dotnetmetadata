import XCTest
@testable import DotNetMetadataFormat

final class CompressedIntsTests: XCTestCase {
    func testUnsigned() {
        func decompressUnsigned(_ bytes: UInt8...) -> UInt32? {
            bytes.withUnsafeBufferPointer { buffer in
                var remainder = UnsafeRawBufferPointer(buffer)
                let result = consumeCompressedUInt(buffer: &remainder)
                XCTAssertEqual(remainder.count, 0)
                return result
            }
        }

        XCTAssertEqual(decompressUnsigned(0x00), 0x00)

        // From §II.23.2
        XCTAssertEqual(decompressUnsigned(0x03), 0x03)
        XCTAssertEqual(decompressUnsigned(0x7F), 0x7F)
        XCTAssertEqual(decompressUnsigned(0x80, 0x80), 0x80)
        XCTAssertEqual(decompressUnsigned(0xAE, 0x57), 0x2E57)
        XCTAssertEqual(decompressUnsigned(0xBF, 0xFF), 0x3FFF)
        XCTAssertEqual(decompressUnsigned(0xC0, 0x00, 0x40, 0x00), 0x4000)
        XCTAssertEqual(decompressUnsigned(0xDF, 0xFF, 0xFF, 0xFF), 0x1FFF_FFFF)
    }

    func testSigned() {
        func decompressSigned(_ bytes: UInt8...) -> Int32? {
            bytes.withUnsafeBufferPointer { buffer in
                var remainder = UnsafeRawBufferPointer(buffer)
                let result = consumeCompressedInt(buffer: &remainder)
                XCTAssertEqual(remainder.count, 0)
                return result
            }
        }

        XCTAssertEqual(decompressSigned(0x00), 0x00)

        // From §II.23.2
        XCTAssertEqual(decompressSigned(0x03), 3)
        XCTAssertEqual(decompressSigned(0x7B), -3)
        XCTAssertEqual(decompressSigned(0x01), -64)
    }
}
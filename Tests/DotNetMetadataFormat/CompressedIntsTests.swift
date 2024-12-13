import Testing
@testable import DotNetMetadataFormat

struct CompressedIntsTests {
    @Test func testUnsigned() {
        func decompressUnsigned(_ bytes: UInt8...) -> UInt32? {
            bytes.withUnsafeBufferPointer { buffer in
                var remainder = UnsafeRawBufferPointer(buffer)
                let result = consumeCompressedUInt(buffer: &remainder)
                #expect(remainder.count == 0)
                return result
            }
        }

        #expect(decompressUnsigned(0x00) == 0x00)

        // From §II.23.2
        #expect(decompressUnsigned(0x03) == 0x03)
        #expect(decompressUnsigned(0x7F) == 0x7F)
        #expect(decompressUnsigned(0x80 == 0x80), 0x80)
        #expect(decompressUnsigned(0xAE == 0x57), 0x2E57)
        #expect(decompressUnsigned(0xBF == 0xFF), 0x3FFF)
        #expect(decompressUnsigned(0xC0, 0x00, 0x40, 0x00) == 0x4000)
        #expect(decompressUnsigned(0xDF, 0xFF, 0xFF, 0xFF) == 0x1FFF_FFFF)
    }
}
import Testing
@testable import DotNetMetadataFormat

struct SignatureTests {
    static func decodeCustomAttrib(_ bytes: [UInt8], paramTypes: [CustomAttribSig.ElemType]) throws -> CustomAttribSig {
        try bytes.withUnsafeBufferPointer { buffer in
            try CustomAttribSig(
                blob: UnsafeRawBufferPointer(buffer),
                paramTypes: paramTypes,
                memberTypeResolver: { _, _, _ in throw InvalidFormatError.signatureBlob })
        }
    }

    @Test func testCustomAttrib_byte() throws {
        let sig = try Self.decodeCustomAttrib(
            [
                0x01, 0x00, // Prolog
                0x42, // Byte fixed arg
                0x00, 0x00, // Num named args
            ],
            paramTypes: [ .integer(size: .int8, signed: true) ]
        )

        #expect(sig.fixedArgs.count == 1)
        #expect(sig.namedArgs.count == 0)
    }
}
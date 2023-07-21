import XCTest
@testable import DotNetMDFormat

final class SignatureTests: XCTestCase {
    static func decodeCustomAttrib(_ bytes: [UInt8], paramTypes: [TypeSig]) throws -> CustomAttribSig {
        try bytes.withUnsafeBufferPointer { buffer in
            try CustomAttribSig(
                blob: UnsafeRawBufferPointer(buffer),
                params: paramTypes.map { ParamSig(customMods: [], byRef: false, type: $0) })
        }
    }

    func testCustomAttrib_byte() throws {
        let _ = try Self.decodeCustomAttrib(
            [
                0x01, 0x00, // Prolog
                0x42, // Byte fixed arg
                0x00, 0x00, // Num named args
            ],
            paramTypes: [ .uint8 ]
        )

        // TODO: Assertions
    }
}
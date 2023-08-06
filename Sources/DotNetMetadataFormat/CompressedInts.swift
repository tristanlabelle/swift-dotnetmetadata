// §II.23.2 / §II.24.2.4, for unsigned integers:
internal func consumeCompressedUInt(buffer: inout UnsafeRawBufferPointer) -> UInt32? {
    guard buffer.count > 0 else { return nil }

    let firstByte = buffer.consume(type: UInt8.self).pointee
    // 23.2> If the value lies between 0 (0x00) and 127 (0x7F), inclusive, encode as a one-byte
    // 23.2> integer (bit 7 is clear, value held in bits 6 through 0)
    // 24.2.4> If the first one byte of the 'blob' is 0bbbbbbb_2 ,
    // 24.2.4> then the rest of the 'blob' contains the bbbbbbb_2 bytes of actual data.
    if firstByte < 0x80 {
        return UInt32(firstByte)
    }
    else {
        let secondByte = buffer.consume(type: UInt8.self).pointee
        // 23.2> If the value lies between 2 8 (0x80) and 2 14 – 1 (0x3FFF), inclusive, encode as a 2-byte
        // 23.2> integer with bit 15 set, bit 14 clear (value held in bits 13 through 0)
        // 24.2.4> If the first two bytes of the 'blob' are 10bbbbbb_2 and x,
        // 24.2.4> then the rest of the 'blob' contains the (bbbbbb_2 << 8 + x) bytes of actual data.
        if firstByte < 0xC0 {
            return (UInt32(firstByte & 0x3F) << 8) | UInt32(secondByte)
        }
        // 23.2> Otherwise, encode as a 4-byte integer, with bit 31 set, bit 30 set, bit 29 clear (value
        // 23.2> held in bits 28 through 0)
        // 24.2.4> If the first four bytes of the 'blob' are 110bbbbb_2 , x, y, and z,
        // 24.2.4> then the rest of the 'blob' contains the (bbbbb_2 << 24 + x << 16 + y << 8 + z) bytes of actual data.
        else if firstByte < 0xE0 {
            let thirdByte = buffer.consume(type: UInt8.self).pointee
            let fourthByte = buffer.consume(type: UInt8.self).pointee
            return (UInt32(firstByte & 0x1F) << 24) | (UInt32(secondByte) << 16) | (UInt32(thirdByte) << 8) | UInt32(fourthByte)
        }
        else {
            return nil
        }
    }
}
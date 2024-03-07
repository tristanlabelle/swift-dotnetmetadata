public enum Constant: Hashable {
    case boolean(Bool)
    case char(UTF16.CodeUnit)
    case int8(Int8)
    case uint8(UInt8)
    case int16(Int16)
    case uint16(UInt16)
    case int32(Int32)
    case uint32(UInt32)
    case int64(Int64)
    case uint64(UInt64)
    case single(Float)
    case double(Double)
    case string(String)
    case null
}

extension Constant {
    public init(buffer: UnsafeRawBufferPointer, type: ConstantType) throws {
        switch (type, buffer.count) {
            case (.boolean, 1): self = .boolean(buffer.loadUnaligned(as: UInt8.self) != 0)
            case (.char, 2): self = .char(buffer.loadUnaligned(as: UTF16.CodeUnit.self))
            case (.i1, 1): self = .int8(buffer.loadUnaligned(as: Int8.self))
            case (.u1, 1): self = .uint8(buffer.loadUnaligned(as: UInt8.self))
            case (.i2, 2): self = .int16(buffer.loadUnaligned(as: Int16.self))
            case (.u2, 2): self = .uint16(buffer.loadUnaligned(as: UInt16.self))
            case (.i4, 4): self = .int32(buffer.loadUnaligned(as: Int32.self))
            case (.u4, 4): self = .uint32(buffer.loadUnaligned(as: UInt32.self))
            case (.i8, 8): self = .int64(buffer.loadUnaligned(as: Int64.self))
            case (.u8, 8): self = .uint64(buffer.loadUnaligned(as: UInt64.self))
            case (.r4, 4): self = .single(buffer.loadUnaligned(as: Float.self))
            case (.r8, 8): self = .double(buffer.loadUnaligned(as: Double.self))
            case (.string, _):
                if let firstCharPointer = buffer.baseAddress?.assumingMemoryBound(to: UTF16.CodeUnit.self) {
                    let charBuffer = UnsafeBufferPointer(start: firstCharPointer, count: buffer.count / 2)
                    self = .string(String(decoding: charBuffer, as: UTF16.self))
                }
                else {
                    self = .string("")
                }
            case (.nullRef, 0): self = .null
            default:
                throw InvalidFormatError.signatureBlob
        }
    }
}

extension Constant {
    public init?(moduleFile: ModuleFile, owner: CodedIndices.HasConstant) throws {
        guard let rowIndex = moduleFile.constantTable.findAny(primaryKey: owner) else {
            return nil
        }

        let constantRow = moduleFile.constantTable[rowIndex]
        guard constantRow.type != .nullRef else {
            self = .null
            return
        }

        let blob = moduleFile.resolve(constantRow.value)
        self = try Constant(buffer: blob, type: constantRow.type)
    }
}
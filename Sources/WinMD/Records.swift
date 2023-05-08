public struct Module: Record {
    public var generation: UInt16
    public var name: StringRef
    public var mvid: GuidRef
    public var encId: GuidRef
    public var encBaseId: GuidRef

    public static var tableIndex: TableIndex { .module }

    public static func getSize(database: Database) -> Int {
        2 + database.stringOffsetSize + database.guidOffsetSize * 3
    }

    public static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        var remainder = buffer
        return Module(
            generation: remainder.consume(type: UInt16.self).pointee,
            name: database.consumeStringRef(buffer: &remainder),
            mvid: database.consumeGuidRef(buffer: &remainder),
            encId: database.consumeGuidRef(buffer: &remainder),
            encBaseId: database.consumeGuidRef(buffer: &remainder))
    }
}

public struct TypeRef: Record {
    var resolutionScope: ResolutionScope
    var typeName: StringRef
    var typeNamespace: StringRef

    public static var tableIndex: TableIndex { .typeRef }

    public static func getSize(database: Database) -> Int {
        database.getCodedIndexSize(ResolutionScope.self) + database.stringOffsetSize * 2
    }

    public static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        var remainder = buffer
        return TypeRef(
            resolutionScope: database.consumeCodedIndex(buffer: &remainder),
            typeName: database.consumeStringRef(buffer: &remainder),
            typeNamespace: database.consumeStringRef(buffer: &remainder))
    }
}

public struct TypeDef: Record {
    public var flags: TypeAttributes
    public var typeName: StringRef
    public var typeNamespace: StringRef
    public var extends: TypeDefOrRef
    var fieldList: TableRowRef<Field>
    var methodList: TableRowRef<MethodDef>

    public static var tableIndex: TableIndex { .typeDef }

    public static func getSize(database: Database) -> Int {
        4 + database.stringOffsetSize * 2 + database.getTableRowIndexSize(.field) + database.getTableRowIndexSize(.methodDef)
    }

    public static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        var remainder = buffer
        fatalError()
    }
}

public struct Field: Record {
    public var flags: FieldAttributes
    public var name: StringRef
    public var signature: BlobRef

    public static var tableIndex: TableIndex { .field }

    public static func getSize(database: Database) -> Int {
        4 + database.stringOffsetSize + database.blobOffsetSize
    }

    public static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        var remainder = buffer
        return Field(
            flags: remainder.consume(type: FieldAttributes.self).pointee,
            name: database.consumeStringRef(buffer: &remainder),
            signature: database.consumeBlobRef(buffer: &remainder))
    }
}

public struct MethodDef: Record {
    public var rva: UInt32
    public var implFlags: MethodImplAttributes
    public var flags: MethodAttributes
    public var name: StringRef
    public var signature: BlobRef
    // public var paramList: TableRowRef<Param>?

    public static var tableIndex: TableIndex { .methodDef }

    public static func getSize(database: Database) -> Int {
        4 + 2 + 2 + database.stringOffsetSize + database.blobOffsetSize
    }

    public static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        var remainder = buffer
        return MethodDef(
            rva: remainder.consume(type: UInt32.self).pointee,
            implFlags: remainder.consume(type: MethodImplAttributes.self).pointee,
            flags: remainder.consume(type: MethodAttributes.self).pointee,
            name: database.consumeStringRef(buffer: &remainder),
            signature: database.consumeBlobRef(buffer: &remainder))
    }
}

public struct Assembly: Record {
    public var hashAlgId: AssemblyHashAlgorithm
    public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    public var flags: AssemblyFlags
    public var publicKey: BlobRef?
    public var name: StringRef
    public var culture: StringRef?

    public static var tableIndex: TableIndex { .assembly }
    public static func getSize(database: Database) -> Int {
        4 + (2 * 4) + 4 + database.blobOffsetSize + database.stringOffsetSize * 2
    }
    
    public static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        fatalError()
    }
}

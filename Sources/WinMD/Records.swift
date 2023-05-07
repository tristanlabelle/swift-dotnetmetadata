public struct Module: RecordProtocol {
    var generation: UInt16
    var name: StringRef
    var mvid: GuidRef
    var encId: GuidRef
    var encBaseId: GuidRef

    public static var tokenKind: MetadataTokenKind { .module }

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

public struct TypeRef: RecordProtocol {
    var resolutionScope: ResolutionScope
    var typeName: StringRef
    var typeNamespace: StringRef

    public static var tokenKind: MetadataTokenKind { .module }

    public static func getSize(database: Database) -> Int {
        2 + database.stringOffsetSize * 2
    }

    public static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        var remainder = buffer
        return TypeRef(
            resolutionScope: database.consumeCodedIndex(buffer: &remainder),
            typeName: database.consumeStringRef(buffer: &remainder),
            typeNamespace: database.consumeStringRef(buffer: &remainder))
    }
}

public struct Assembly: RecordProtocol {
    var hashAlgId: CLI.AssemblyHashAlgorithm
    var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    var flags: CLI.AssemblyFlags
    var publicKey: BlobRef?
    var name: StringRef
    var culture: StringRef?

    public static var tokenKind: MetadataTokenKind { .assembly }
    public static func getSize(database: Database) -> Int {
        4 + (2 * 4) + 4 + database.blobOffsetSize + database.stringOffsetSize * 2
    }
    
    public static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        fatalError()
    }
}

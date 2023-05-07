struct Assembly: RecordProtocol {
    var hashAlgId: CLI.AssemblyHashAlgorithm
    var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    var flags: CLI.AssemblyFlags
    var publicKey: BlobRef?
    var name: StringRef
    var culture: StringRef?

    static var tokenKind: CLI.MetadataTokenKind { .assembly }
    static func getSize(database: Database) -> Int {
        4 + (2 * 4) + 4 + database.blobOffsetSize + database.stringOffsetSize * 2
    }
    
    static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        fatalError()
    }
}

struct Module: RecordProtocol {
    var name: StringRef

    static var tokenKind: CLI.MetadataTokenKind { .module }

    static func getSize(database: Database) -> Int {
        2 + database.stringOffsetSize + database.guidOffsetSize * 3
    }

    static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        fatalError()
    }
}
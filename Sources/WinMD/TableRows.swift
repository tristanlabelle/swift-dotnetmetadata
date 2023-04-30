struct ModuleRow: TableRow {
    var name: StringRef

    static var tokenKind: CLI.MetadataTokenKind { .module }

    static func getSize(database: Database) -> Int {
        2 + database.stringHeap.offsetSize + database.guidHeap.offsetSize * 3
    }

    static func read(buffer: UnsafeRawBufferPointer, database: Database) -> Self {
        fatalError()
    }
}
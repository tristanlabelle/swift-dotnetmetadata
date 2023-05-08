extension Database {
    struct MetadataRoot_BeforeVersion {
        var signature: UInt32
        var majorVersion: UInt16, minorVersion: UInt16
        var reserved: UInt32
        var length: UInt32
        // Null-padded version string of the given length follows
    }

    struct MetadataRoot_AfterVersion {
        var flags: UInt16
        var streams: UInt16
        // Stream header array follows
    }

    struct MetadataStreamHeader {
        var offset: UInt32
        var size: UInt32
        // Null-terminated name string follows
    }

    /// Represents the "#~" stream, as defined in ECMA 335 II.24.2.6.
    struct MetadataTablesStreamHeader {
        var reserved0: UInt32 // Always 0
        var majorVersion: UInt8, minorVersion: UInt8
        var heapSizes: UInt8
        var reserved1: UInt8 // Always 1
        var valid: UInt64
        var sorted: UInt64
        // Row counts per table follow
        // Metadata tables follow
    }

    struct MetadataTableInfo {
        var Offset: UInt32
        var RowCount: UInt32
        var BytesPerRow: UInt32
    }
}
enum CLI {
    struct MetadataRoot_BeforeVersion {
        var Signature: UInt32
        var MajorVersion: UInt16, MinorVersion: UInt16
        var Reserved: UInt32
        var Length: UInt32
        // Null-padded version string of the given length follows
    }

    struct MetadataRoot_AfterVersion {
        var Flags: UInt16
        var Streams: UInt16
        // Stream header array follows
    }

    struct MetadataStreamHeader {
        var Offset: UInt32
        var Size: UInt32
        // Null-terminated name string follows
    }

    /// Represents the "#~" stream, as defined in ECMA 335 II.24.2.6.
    struct MetadataTablesStreamHeader {
        var Reserved0: UInt32 // Always 0
        var MajorVersion: UInt8, MinorVersion: UInt8
        var HeapSizes: UInt8
        var Reserved1: UInt8 // Always 1
        var Valid: UInt64
        var Sorted: UInt64
        // Row counts per table follow
        // Metadata tables follow
    }

    struct MetadataTableInfo {
        var Offset: UInt32
        var RowCount: UInt32
        var BytesPerRow: UInt32
    }
}
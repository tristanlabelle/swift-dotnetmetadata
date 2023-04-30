enum CLI {
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

    enum MetadataTokenKind: UInt8 {
        case module = 0x00
        case typeReference = 0x01
        case type = 0x02
        case field = 0x04
        case method = 0x06
        case parameter = 0x08
        case interfaceImplementation = 0x09
        case memberReference = 0x0A
        case constant = 0x0B
        case customAttribute = 0x0C
        case fieldMarshal = 0x0D
        case declarativeSecurity = 0x0E
        case classLayout = 0x0F
        case fieldLayout = 0x10
        case signature = 0x11
        case eventMap = 0x12
        case event = 0x14
        case propertyMap = 0x15
        case property = 0x17
        case methodSemantics = 0x18
        case methodImplementation = 0x19
        case moduleReference = 0x1A
        case typeSpecification = 0x1B
        case implementationMap = 0x1C
        case fieldRva = 0x1D
        case assembly = 0x20
        case assemblyProcessor = 0x21
        case assemblyOS = 0x22
        case assemblyReference = 0x23
        case assemblyReferenceProcessor = 0x24
        case assemblyReferenceOS = 0x25
        case file = 0x26
        case exportedType = 0x27
        case manifestResource = 0x28
        case nestedClass = 0x29
        case genericParameter = 0x2A
        case methodSpecification = 0x2B
        case genericParameterConstraint = 0x2C
        case string = 0x70
        case name = 0x71
        case baseType = 0x72
    }
}
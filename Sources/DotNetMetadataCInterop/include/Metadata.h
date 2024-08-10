#ifndef COR_HEADER
#define COR_HEADER

#include <stdint.h>

typedef struct {
    uint32_t Signature;
    uint16_t MajorVersion, MinorVersion;
    uint32_t Reserved;
    uint32_t Length;
    // Null-padded version string of the given length follows
} MetadataRoot_BeforeVersion;

typedef struct {
    uint16_t Flags;
    uint16_t Streams;
    // Stream header array follows
} MetadataRoot_AfterVersion;

typedef struct {
    uint32_t Offset;
    uint32_t Size;
    // Null-terminated name string follows
} MetadataStreamHeader;

/// Represents the "#~" stream, as defined in ECMA 335 II.24.2.6.
typedef struct {
    uint32_t Reserved0; // Always 0
    uint8_t MajorVersion, MinorVersion;
    uint8_t HeapSizes;
    uint8_t Reserved1; // Always 1
    uint64_t Valid;
    uint64_t Sorted;
    // Row counts per table follow
    // Metadata tables follow
} MetadataTablesStreamHeader;

typedef struct {
    uint32_t Offset;
    uint32_t RowCount;
    uint32_t BytesPerRow;
} MetadataTableInfo;

#endif
#ifndef COR_HEADER
#define COR_HEADER

#include <stdint.h>
#include "PE.h"

typedef struct {
    uint32_t cb;
    uint16_t MajorRuntimeVersion, MinorRuntimeVersion;
    CINTEROP_IMAGE_DATA_DIRECTORY MetaData;
    uint32_t Flags;
    union {
        uint32_t EntryPointToken;
        uint32_t EntryPointRVA;
    };
    CINTEROP_IMAGE_DATA_DIRECTORY Resources;
    CINTEROP_IMAGE_DATA_DIRECTORY StrongNameSignature;
    CINTEROP_IMAGE_DATA_DIRECTORY CodeManagerTable;
    CINTEROP_IMAGE_DATA_DIRECTORY VTableFixups;
    CINTEROP_IMAGE_DATA_DIRECTORY ExportAddressTableJumps;
    CINTEROP_IMAGE_DATA_DIRECTORY ManagedNativeHeader;
} CINTEROP_IMAGE_COR20_HEADER;

#endif
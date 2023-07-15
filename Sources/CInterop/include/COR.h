#include <stdint.h>
#include "PE.h"

typedef struct {
    uint32_t cb;
    uint16_t MajorRuntimeVersion, MinorRuntimeVersion;
    IMAGE_DATA_DIRECTORY MetaData;
    uint32_t Flags;
    union {
        uint32_t EntryPointToken;
        uint32_t EntryPointRVA;
    };
    IMAGE_DATA_DIRECTORY Resources;
    IMAGE_DATA_DIRECTORY StrongNameSignature;
    IMAGE_DATA_DIRECTORY CodeManagerTable;
    IMAGE_DATA_DIRECTORY VTableFixups;
    IMAGE_DATA_DIRECTORY ExportAddressTableJumps;
    IMAGE_DATA_DIRECTORY ManagedNativeHeader;
} IMAGE_COR20_HEADER;
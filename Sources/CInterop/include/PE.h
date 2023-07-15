#ifndef PE_HEADER
#define PE_HEADER

#include <stdint.h>

// CINTEROP_ prefixes are a workaround for a compiler crash
// because of ambiguous name references due to an implicitly
// included winnt.h.

#define CINTEROP_IMAGE_DOS_SIGNATURE 0x5A4D // MZ
#define CINTEROP_IMAGE_NT_SIGNATURE 0x00004550 // PE\0\0
#define CINTEROP_IMAGE_NT_OPTIONAL_HDR32_MAGIC 0x10b
#define CINTEROP_IMAGE_NT_OPTIONAL_HDR64_MAGIC 0x20b
#define CINTEROP_IMAGE_SIZEOF_SHORT_NAME 8
#define CINTEROP_IMAGE_NUMBEROF_DIRECTORY_ENTRIES 16
#define CINTEROP_IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR 14

typedef struct {
    uint16_t e_magic;
    uint16_t e_cblp;
    uint16_t e_cp;
    uint16_t e_crlc;
    uint16_t e_cparhdr;
    uint16_t e_minalloc;
    uint16_t e_maxalloc;
    uint16_t e_ss;
    uint16_t e_sp;
    uint16_t e_csum;
    uint16_t e_ip;
    uint16_t e_cs;
    uint16_t e_lfarlc;
    uint16_t e_ovno;
    uint16_t e_res[4];
    uint16_t e_oemid;
    uint16_t e_oeminfo;
    uint16_t e_res2[10];
    int32_t e_lfanew;
} CINTEROP_IMAGE_DOS_HEADER;

typedef struct {
    uint16_t Machine;
    uint16_t NumberOfSections;
    uint32_t TimeDateStamp;
    uint32_t PointerToSymbolTable;
    uint32_t NumberOfSymbols;
    uint16_t SizeOfOptionalHeader;
    uint16_t Characteristics;
} CINTEROP_IMAGE_FILE_HEADER;

typedef struct {
    uint32_t VirtualAddress;
    uint32_t Size;
} CINTEROP_IMAGE_DATA_DIRECTORY;

typedef struct {
    uint16_t Magic;
    uint8_t MajorLinkerVersion, MinorLinkerVersion;
    uint32_t SizeOfCode;
    uint32_t SizeOfInitializedData;
    uint32_t SizeOfUninitializedData;
    uint32_t AddressOfEntryPoint;
    uint32_t BaseOfCode;
    uint32_t BaseOfData;
    uint32_t ImageBase;
    uint32_t SectionAlignment;
    uint32_t FileAlignment;
    uint16_t MajorOperatingSystemVersion, MinorOperatingSystemVersion;
    uint16_t MajorImageVersion, MinorImageVersion;
    uint16_t MajorSubsystemVersion, MinorSubsystemVersion;
    uint32_t Win32VersionValue;
    uint32_t SizeOfImage;
    uint32_t SizeOfHeaders;
    uint32_t CheckSum;
    uint16_t Subsystem;
    uint16_t DllCharacteristics;
    uint32_t SizeOfStackReserve;
    uint32_t SizeOfStackCommit;
    uint32_t SizeOfHeapReserve;
    uint32_t SizeOfHeapCommit;
    uint32_t LoaderFlags;
    uint32_t NumberOfRvaAndSizes;
    CINTEROP_IMAGE_DATA_DIRECTORY DataDirectory[CINTEROP_IMAGE_NUMBEROF_DIRECTORY_ENTRIES];
} CINTEROP_IMAGE_OPTIONAL_HEADER32;

typedef struct {
    uint32_t Signature;
    CINTEROP_IMAGE_FILE_HEADER FileHeader;
    CINTEROP_IMAGE_OPTIONAL_HEADER32 OptionalHeader;
} CINTEROP_IMAGE_NT_HEADERS32;

typedef struct {
    uint16_t Magic;
    uint8_t MajorLinkerVersion, MinorLinkerVersion;
    uint32_t SizeOfCode;
    uint32_t SizeOfInitializedData;
    uint32_t SizeOfUninitializedData;
    uint32_t AddressOfEntryPoint;
    uint32_t BaseOfCode;
    uint64_t ImageBase;
    uint32_t SectionAlignment;
    uint32_t FileAlignment;
    uint16_t MajorOperatingSystemVersion, MinorOperatingSystemVersion;
    uint16_t MajorImageVersion, MinorImageVersion;
    uint16_t MajorSubsystemVersion, MinorSubsystemVersion;
    uint32_t Win32VersionValue;
    uint32_t SizeOfImage;
    uint32_t SizeOfHeaders;
    uint32_t CheckSum;
    uint16_t Subsystem;
    uint16_t DllCharacteristics;
    uint64_t SizeOfStackReserve;
    uint64_t SizeOfStackCommit;
    uint64_t SizeOfHeapReserve;
    uint64_t SizeOfHeapCommit;
    uint32_t LoaderFlags;
    uint32_t NumberOfRvaAndSizes;
    CINTEROP_IMAGE_DATA_DIRECTORY DataDirectory[CINTEROP_IMAGE_NUMBEROF_DIRECTORY_ENTRIES];
} CINTEROP_IMAGE_OPTIONAL_HEADER64;

typedef struct {
    uint32_t Signature;
    CINTEROP_IMAGE_FILE_HEADER FileHeader;
    CINTEROP_IMAGE_OPTIONAL_HEADER64 OptionalHeader;
} CINTEROP_IMAGE_NT_HEADERS64;

typedef struct {
    uint8_t Name[CINTEROP_IMAGE_SIZEOF_SHORT_NAME];
    union {
        uint32_t PhysicalAddress;
        uint32_t VirtualSize;
    } Misc;
    uint32_t VirtualAddress;
    uint32_t SizeOfRawData;
    uint32_t PointerToRawData;
    uint32_t PointerToRelocations;
    uint32_t PointerToLinenumbers;
    uint16_t NumberOfRelocations;
    uint16_t NumberOfLineNumbers;
    uint32_t Characteristics;
} CINTEROP_IMAGE_SECTION_HEADER;

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
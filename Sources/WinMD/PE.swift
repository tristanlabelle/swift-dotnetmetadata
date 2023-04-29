enum PE {
    struct ImageDOSHeader {
        var e_signature: UInt16
        var e_cblp: UInt16
        var e_cp: UInt16
        var e_crlc: UInt16
        var e_cparhdr: UInt16
        var e_minalloc: UInt16
        var e_maxalloc: UInt16
        var e_ss: UInt16
        var e_sp: UInt16
        var e_csum: UInt16
        var e_ip: UInt16
        var e_cs: UInt16
        var e_lfarlc: UInt16
        var e_ovno: UInt16
        // UInt16 e_res[4]
        var e_res_0: UInt16, e_res_1: UInt16, e_res_2: UInt16, e_res_3: UInt16
        var e_oemid: UInt16
        var e_oeminfo: UInt16
        // UInt16 e_res2[10];
        var e_res2_0: UInt16, e_res2_1: UInt16, e_res2_2: UInt16, e_res2_3: UInt16, e_res2_4: UInt16,
            e_res2_5: UInt16, e_res2_6: UInt16, e_res2_7: UInt16, e_res2_8: UInt16, e_res2_9: UInt16
        var e_lfanew: Int32
    }

    struct ImageFileHeader {
        var Machine: UInt16
        var NumberOfSections: UInt16
        var TimeDateStamp: UInt32
        var PointerToSymbolTable: UInt32
        var NumberOfSymbols: UInt32
        var SizeOfOptionalHeader: UInt16
        var Characteristics: UInt16
    }

    struct ImageDataDirectory {
        var VirtualAddress: UInt32
        var Size: UInt32
    }

    struct ImageOptionalHeader32 {
        var Magic: UInt16
        var MajorLinkerVersion: UInt8
        var MinorLinkerVersion: UInt8
        var SizeOfCode: UInt32
        var SizeOfInitializedData: UInt32
        var SizeOfUninitializedData: UInt32
        var AddressOfEntryPoint: UInt32
        var BaseOfCode: UInt32
        var BaseOfData: UInt32
        var ImageBase: UInt32
        var SectionAlignment: UInt32
        var FileAlignment: UInt32
        var MajorOperatingSystemVersion: UInt16
        var MinorOperatingSystemVersion: UInt16
        var MajorImageVersion: UInt16
        var MinorImageVersion: UInt16
        var MajorSubsystemVersion: UInt16
        var MinorSubsystemVersion: UInt16
        var Win32VersionValue: UInt32
        var SizeOfImage: UInt32
        var SizeOfHeaders: UInt32
        var CheckSum: UInt32
        var Subsystem: UInt16
        var DllCharacteristics: UInt16
        var SizeOfStackReserve: UInt32
        var SizeOfStackCommit: UInt32
        var SizeOfHeapReserve: UInt32
        var SizeOfHeapCommit: UInt32
        var LoaderFlags: UInt32
        var NumberOfRvaAndSizes: UInt32
        // ImageDataDirectory DataDirectory[16];
        var DataDirectory_0: ImageDataDirectory, DataDirectory_1: ImageDataDirectory, DataDirectory_2: ImageDataDirectory, DataDirectory_3: ImageDataDirectory,
            DataDirectory_4: ImageDataDirectory, DataDirectory_5: ImageDataDirectory, DataDirectory_6: ImageDataDirectory, DataDirectory_7: ImageDataDirectory,
            DataDirectory_8: ImageDataDirectory, DataDirectory_9: ImageDataDirectory, DataDirectory_10: ImageDataDirectory, DataDirectory_11: ImageDataDirectory,
            DataDirectory_12: ImageDataDirectory, DataDirectory_13: ImageDataDirectory, DataDirectory_14: ImageDataDirectory, DataDirectory_15: ImageDataDirectory
    }

    struct ImageNTHeaders32 {
        var Signature: UInt32
        var FileHeader: ImageFileHeader
        var OptionalHeader: ImageOptionalHeader32
    }

    struct ImageOptionalHeaders32
    {
        var Magic: UInt16
        var MajorLinkerVersion: UInt8
        var MinorLinkerVersion: UInt8
        var SizeOfCode: UInt32
        var SizeOfInitializedData: UInt32
        var SizeOfUninitializedData: UInt32
        var AddressOfEntryPoint: UInt32
        var BaseOfCode: UInt32
        var ImageBase: UInt64
        var SectionAlignment: UInt32
        var FileAlignment: UInt32
        var MajorOperatingSystemVersion: UInt16
        var MinorOperatingSystemVersion: UInt16
        var MajorImageVersion: UInt16
        var MinorImageVersion: UInt16
        var MajorSubsystemVersion: UInt16
        var MinorSubsystemVersion: UInt16
        var Win32VersionValue: UInt32
        var SizeOfImage: UInt32
        var SizeOfHeaders: UInt32
        var CheckSum: UInt32
        var Subsystem: UInt16
        var DllCharacteristics: UInt16
        var SizeOfStackReserve: UInt64
        var SizeOfStackCommit: UInt64
        var SizeOfHeapReserve: UInt64
        var SizeOfHeapCommit: UInt64
        var LoaderFlags: UInt32
        var NumberOfRvaAndSizes: UInt32
        // ImageDataDirectory DataDirectory[16];
        var DataDirectory_0: ImageDataDirectory, DataDirectory_1: ImageDataDirectory, DataDirectory_2: ImageDataDirectory, DataDirectory_3: ImageDataDirectory,
            DataDirectory_4: ImageDataDirectory, DataDirectory_5: ImageDataDirectory, DataDirectory_6: ImageDataDirectory, DataDirectory_7: ImageDataDirectory,
            DataDirectory_8: ImageDataDirectory, DataDirectory_9: ImageDataDirectory, DataDirectory_10: ImageDataDirectory, DataDirectory_11: ImageDataDirectory,
            DataDirectory_12: ImageDataDirectory, DataDirectory_13: ImageDataDirectory, DataDirectory_14: ImageDataDirectory, DataDirectory_15: ImageDataDirectory
    }

    struct ImageNTHeaders32Plus {
        var Signature: UInt32
        var FileHeader: ImageFileHeader
        var OptionalHeader: ImageOptionalHeaders32
    }

    struct ImageSectionHeader {
        // UInt8 Name[8], where 8 == IMAGE_SIZEOF_SHORT_NAME
        var Name_0: UInt8, Name_1: UInt8, Name_2: UInt8, Name_3: UInt8,
            Name_4: UInt8, Name_5: UInt8, Name_6: UInt8, Name_7: UInt8
        var Misc: UInt32
        var PhysicalAddress: UInt32 { get { Misc } set { Misc = newValue } }
        var VirtualSize: UInt32 { get { Misc } set { Misc = newValue } }
        var VirtualAddress: UInt32
        var SizeOfRawData: UInt32
        var PointerToRawData: UInt32
        var PointerToRelocations: UInt32
        var PointerToLinenumbers: UInt32
        var NumberOfRelocations: UInt16
        var NumberOfLinenumbers: UInt16
        var Characteristics: UInt32
    }

    struct ImageCor20Header {
        var cb: UInt32
        var MajorRuntimeVersion: UInt16
        var MinorRuntimeVersion: UInt16
        var MetaData: ImageDataDirectory
        var Flags: UInt32
        var EntryPoint: UInt32
        var EntryPointToken: UInt32 { get { EntryPoint } set { EntryPoint = newValue } }
        var EntryPointRVA: UInt32 { get { EntryPoint } set { EntryPoint = newValue } }
        var Resources: ImageDataDirectory
        var StrongNameSignature: ImageDataDirectory
        var CodeManagerTable: ImageDataDirectory
        var VTableFixups: ImageDataDirectory
        var ExportAddressTableJumps: ImageDataDirectory
        var ManagedNativeHeader: ImageDataDirectory
    }
}
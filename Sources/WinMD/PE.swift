enum PE {
    public struct ImageDOSHeader {
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

    public struct ImageNTHeaders32 {
        var signature: UInt32
        var fileHeader: ImageFileHeader
        var optionalHeader: ImageOptionalHeader64
    }

    public struct ImageFileHeader {
        var machine: UInt16
        var numberOfSections: UInt16
        var timeDateStamp: UInt32
        var pointerToSymbolTable: UInt32
        var numberOfSymbols: UInt32
        var sizeOfOptionalHeader: UInt16
        var characteristics: UInt16
    }

    public struct ImageOptionalHeader32 {
        var magic: UInt16
        var majorLinkerVersion: UInt8, minorLinkerVersion: UInt8
        var sizeOfCode: UInt32
        var sizeOfInitializedData: UInt32
        var sizeOfUninitializedData: UInt32
        var addressOfEntryPoint: UInt32
        var baseOfCode: UInt32
        var baseOfData: UInt32
        var imageBase: UInt32
        var sectionAlignment: UInt32
        var fileAlignment: UInt32
        var majorOperatingSystemVersion: UInt16, minorOperatingSystemVersion: UInt16
        var majorImageVersion: UInt16, minorImageVersion: UInt16
        var majorSubsystemVersion: UInt16, minorSubsystemVersion: UInt16
        var win32VersionValue: UInt32
        var sizeOfImage: UInt32
        var sizeOfHeaders: UInt32
        var checkSum: UInt32
        var subsystem: UInt16
        var dllCharacteristics: UInt16
        var sizeOfStackReserve: UInt32
        var sizeOfStackCommit: UInt32
        var sizeOfHeapReserve: UInt32
        var sizeOfHeapCommit: UInt32
        var loaderFlags: UInt32
        var numberOfRvaAndSizes: UInt32
        // ImageDataDirectory DataDirectory[16];
        var dataDirectory_0: ImageDataDirectory, dataDirectory_1: ImageDataDirectory, dataDirectory_2: ImageDataDirectory, dataDirectory_3: ImageDataDirectory,
            dataDirectory_4: ImageDataDirectory, dataDirectory_5: ImageDataDirectory, dataDirectory_6: ImageDataDirectory, dataDirectory_7: ImageDataDirectory,
            dataDirectory_8: ImageDataDirectory, dataDirectory_9: ImageDataDirectory, dataDirectory_10: ImageDataDirectory, dataDirectory_11: ImageDataDirectory,
            dataDirectory_12: ImageDataDirectory, dataDirectory_13: ImageDataDirectory, dataDirectory_14: ImageDataDirectory, dataDirectory_15: ImageDataDirectory
    }

    public struct ImageDataDirectory {
        var virtualAddress: UInt32
        var size: UInt32
    }

    public struct ImageNTHeaders64 {
        var signature: UInt32
        var fileHeader: ImageFileHeader
        var optionalHeader: ImageOptionalHeader64
    }

    public struct ImageOptionalHeader64 {
        var magic: UInt16
        var majorLinkerVersion: UInt8, minorLinkerVersion: UInt8
        var sizeOfCode: UInt32
        var sizeOfInitializedData: UInt32
        var sizeOfUninitializedData: UInt32
        var addressOfEntryPoint: UInt32
        var baseOfCode: UInt32
        var imageBase: UInt64
        var sectionAlignment: UInt32
        var fileAlignment: UInt32
        var majorOperatingSystemVersion: UInt16, minorOperatingSystemVersion: UInt16
        var majorImageVersion: UInt16, minorImageVersion: UInt16
        var majorSubsystemVersion: UInt16, minorSubsystemVersion: UInt16
        var win32VersionValue: UInt32
        var sizeOfImage: UInt32
        var sizeOfHeaders: UInt32
        var checkSum: UInt32
        var subsystem: UInt16
        var dllCharacteristics: UInt16
        var sizeOfStackReserve: UInt64
        var sizeOfStackCommit: UInt64
        var sizeOfHeapReserve: UInt64
        var sizeOfHeapCommit: UInt64
        var loaderFlags: UInt32
        var numberOfRvaAndSizes: UInt32
        // ImageDataDirectory DataDirectory[16];
        var dataDirectory_0: ImageDataDirectory, dataDirectory_1: ImageDataDirectory, dataDirectory_2: ImageDataDirectory, dataDirectory_3: ImageDataDirectory,
            dataDirectory_4: ImageDataDirectory, dataDirectory_5: ImageDataDirectory, dataDirectory_6: ImageDataDirectory, dataDirectory_7: ImageDataDirectory,
            dataDirectory_8: ImageDataDirectory, dataDirectory_9: ImageDataDirectory, dataDirectory_10: ImageDataDirectory, dataDirectory_11: ImageDataDirectory,
            dataDirectory_12: ImageDataDirectory, dataDirectory_13: ImageDataDirectory, dataDirectory_14: ImageDataDirectory, dataDirectory_15: ImageDataDirectory
    }

    public struct ImageSectionHeader {
        // UInt8 Name[8], where 8 == IMAGE_SIZEOF_SHORT_NAME
        var name_0: UInt8, name_1: UInt8, name_2: UInt8, name_3: UInt8,
            name_4: UInt8, name_5: UInt8, name_6: UInt8, name_7: UInt8
        var misc: UInt32
        var physicalAddress: UInt32 { get { misc } set { misc = newValue } }
        var virtualSize: UInt32 { get { misc } set { misc = newValue } }
        var virtualAddress: UInt32
        var sizeOfRawData: UInt32
        var pointerToRawData: UInt32
        var pointerToRelocations: UInt32
        var pointerToLinenumbers: UInt32
        var numberOfRelocations: UInt16
        var numberOfLineNumbers: UInt16
        var characteristics: UInt32
    }

    struct ImageCor20Header {
        var cb: UInt32
        var majorRuntimeVersion: UInt16, minorRuntimeVersion: UInt16
        var metaData: ImageDataDirectory
        var flags: UInt32
        var entryPoint: UInt32
        var entryPointToken: UInt32 { get { entryPoint } set { entryPoint = newValue } }
        var entryPointRVA: UInt32 { get { entryPoint } set { entryPoint = newValue } }
        var resources: ImageDataDirectory
        var strongNameSignature: ImageDataDirectory
        var codeManagerTable: ImageDataDirectory
        var vtableFixups: ImageDataDirectory
        var exportAddressTableJumps: ImageDataDirectory
        var managedNativeHeader: ImageDataDirectory
    }
}
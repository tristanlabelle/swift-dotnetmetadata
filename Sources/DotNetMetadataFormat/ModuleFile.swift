import CInterop
import Foundation

/// A view of the CLI metadata embedded in a module file (.dll, .exe or .winmd).
/// Module files are commonly referred to as assemblies, but this is incorrect
/// since an assembly is a higher-level construct which can consist of multiple module files.
public final class ModuleFile {
    private struct MetadataRoot {
        var majorVersion: UInt16, minorVersion: UInt16
        var versionString: String
        var flags: UInt16
        var streamHeaders: [String: MetadataStreamHeader] = [:]
    }

    private let data: Data
    public let url: URL?

    // Metadata heaps
    public let stringHeap: StringHeap
    public let guidHeap: GuidHeap
    public let blobHeap: BlobHeap

    // Metadata tables, in table ID order
    public let moduleTable: ModuleTable
    public let typeRefTable: TypeRefTable
    public let typeDefTable: TypeDefTable
    public let fieldTable: FieldTable
    public let methodDefTable: MethodDefTable
    public let paramTable: ParamTable
    public let interfaceImplTable: InterfaceImplTable
    public let memberRefTable: MemberRefTable
    public let constantTable: ConstantTable
    public let customAttributeTable: CustomAttributeTable
    public let fieldMarshalTable: FieldMarshalTable
    public let declSecurityTable: DeclSecurityTable
    public let classLayoutTable: ClassLayoutTable
    public let fieldLayoutTable: FieldLayoutTable
    public let standAloneSigTable: StandAloneSigTable
    public let eventMapTable: EventMapTable
    public let eventTable: EventTable
    public let propertyMapTable: PropertyMapTable
    public let propertyTable: PropertyTable
    public let methodSemanticsTable: MethodSemanticsTable
    public let methodImplTable: MethodImplTable
    public let moduleRefTable: ModuleRefTable
    public let typeSpecTable: TypeSpecTable
    public let implMapTable: ImplMapTable
    public let fieldRvaTable: FieldRvaTable
    public let assemblyTable: AssemblyTable
    public let assemblyRefTable: AssemblyRefTable
    public let fileTable: FileTable
    public let exportedTypeTable: ExportedTypeTable
    public let manifestResourceTable: ManifestResourceTable
    public let nestedClassTable: NestedClassTable
    public let genericParamTable: GenericParamTable
    public let methodSpecTable: MethodSpecTable
    public let genericParamConstraintTable: GenericParamConstraintTable

    public init(data: Data, url: URL? = nil) throws {
        self.data = data
        self.url = url

        let buffer = data.withUnsafeBytes { $0 }
        let buffer2 = data.withUnsafeBytes { $0 }
        guard buffer2.baseAddress == buffer.baseAddress && buffer2.count == buffer.count else {
            fatalError("ModuleFile data is not pinned")
        }

        let peView = try PEView(file: buffer)

        let cliHeader = peView.resolve(peView.dataDirectories[Int(CINTEROP_IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR)])
            .bindMemory(offset: 0, to: CINTEROP_IMAGE_COR20_HEADER.self)
        guard cliHeader.pointee.cb == MemoryLayout<CINTEROP_IMAGE_COR20_HEADER>.stride else { throw InvalidFormatError.cliHeader }

        let metadataSection = peView.resolve(virtualAddress: cliHeader.pointee.MetaData.VirtualAddress, size: cliHeader.pointee.MetaData.Size)
        let metadataRoot = try Self.readMetadataRoot(metadataSection: metadataSection)

        // Read heap streams
        stringHeap = StringHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#Strings"]))
        guidHeap = GuidHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#GUID"]))
        blobHeap = BlobHeap(buffer: Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#Blob"]))

        // Read tables stream
        var tablesStreamRemainder = Self.getStream(metadataSection: metadataSection, header: metadataRoot.streamHeaders["#~"])
        let tablesStreamHeader = tablesStreamRemainder.consume(type: MetadataTablesStreamHeader.self)
        guard tablesStreamHeader.pointee.MajorVersion == 2 && tablesStreamHeader.pointee.MinorVersion == 0 else {
            throw InvalidFormatError.cliHeader
        }

        let tableRowCounts = (0 ..< TableID.count).map {
            let isTablePresent = (tablesStreamHeader.pointee.Valid & (TableID.BitSet(1) << $0)) != 0
            return isTablePresent ? tablesStreamRemainder.consume(type: UInt32.self).pointee : UInt32(0)
        }

        let tableSizes = TableSizes(heapSizingBits: tablesStreamHeader.pointee.HeapSizes, tableRowCounts: tableRowCounts)
        var nextTableID = 0

        // We must read all tables in order and without any gaps
        func consumeTable<Row: TableRow>() -> Table<Row> {
            // Make sure we're not skipping any tables with non-zero rows
            while nextTableID < Row.tableID.rawValue {
                guard tableSizes.getRowCount(nextTableID) == 0
                else { fatalError("Not implemented: reading \(TableID(rawValue: UInt8(nextTableID))!) metadata table") }
                nextTableID += 1
            }

            let rowCount = tableSizes.getRowCount(Row.tableID)
            let size = Row.getSize(sizes: tableSizes) * rowCount
            let sorted = ((tablesStreamHeader.pointee.Sorted >> Row.tableID.rawValue) & 1) == 1
            nextTableID += 1
            return Table(buffer: tablesStreamRemainder.consume(count: size), sizes: tableSizes, sorted: sorted)
        } 

        moduleTable = consumeTable()
        typeRefTable = consumeTable()
        typeDefTable = consumeTable()
        fieldTable = consumeTable()
        methodDefTable = consumeTable()
        paramTable = consumeTable()
        interfaceImplTable = consumeTable()
        memberRefTable = consumeTable()
        constantTable = consumeTable()
        customAttributeTable = consumeTable()
        fieldMarshalTable = consumeTable()
        declSecurityTable = consumeTable()
        classLayoutTable = consumeTable()
        fieldLayoutTable = consumeTable()
        standAloneSigTable = consumeTable()
        eventMapTable = consumeTable()
        eventTable = consumeTable()
        propertyMapTable = consumeTable()
        propertyTable = consumeTable()
        methodSemanticsTable = consumeTable()
        methodImplTable = consumeTable()
        moduleRefTable = consumeTable()
        typeSpecTable = consumeTable()
        implMapTable = consumeTable()
        fieldRvaTable = consumeTable()
        assemblyTable = consumeTable()
        assemblyRefTable = consumeTable()
        fileTable = consumeTable()
        exportedTypeTable = consumeTable()
        manifestResourceTable = consumeTable()
        nestedClassTable = consumeTable()
        genericParamTable = consumeTable()
        methodSpecTable = consumeTable()
        genericParamConstraintTable = consumeTable()
    }

    public convenience init(path: String) throws {
        try self.init(url: URL(fileURLWithPath: path))
    }

    public convenience init(url: URL) throws {
        try self.init(data: try Data(contentsOf: url, options: .mappedIfSafe), url: url)
    }

    private static func getStream(metadataSection: UnsafeRawBufferPointer, header: MetadataStreamHeader?) -> UnsafeRawBufferPointer {
        guard let header = header else { return UnsafeRawBufferPointer.empty }
        return metadataSection.sub(offset: Int(header.Offset), count: Int(header.Size))
    }

    private static func readMetadataRoot(metadataSection: UnsafeRawBufferPointer) throws -> MetadataRoot {
        var remainder = metadataSection

        let beforeVersion = remainder.consume(type: MetadataRoot_BeforeVersion.self)
        guard beforeVersion.pointee.Signature == 0x424a5342 else { throw InvalidFormatError.cliHeader }

        let versionStringPaddedLength = (Int(beforeVersion.pointee.Length) + 3) & ~0x3
        let versionStringPaddedBytes = remainder.consume(count: versionStringPaddedLength)
        let versionString = String(bytes: versionStringPaddedBytes.sub(offset: 0, count: Int(beforeVersion.pointee.Length)), encoding: .utf8)!

        let afterVersion = remainder.consume(type: MetadataRoot_AfterVersion.self)

        var streamHeaders: [String: MetadataStreamHeader] = [:]
        for _ in 0 ..< Int(afterVersion.pointee.Streams) {
            let streamHeader = remainder.consume(type: MetadataStreamHeader.self)
            let streamName = remainder.consumeDwordPaddedUTF8String()
            streamHeaders[streamName] = streamHeader.pointee
        }

        return MetadataRoot(
            majorVersion: beforeVersion.pointee.MajorVersion,
            minorVersion: beforeVersion.pointee.MinorVersion,
            versionString: versionString,
            flags: afterVersion.pointee.Flags,
            streamHeaders: streamHeaders)
    }

    public func resolve(_ offset: StringHeap.Offset) -> String {
        stringHeap.resolve(at: offset.value)
    }

    public func resolve(_ offset: GuidHeap.Offset) -> UUID {
        guidHeap.resolve(at: offset.value)
    }

    public func resolve(_ offset: BlobHeap.Offset) -> UnsafeRawBufferPointer {
        blobHeap.resolve(at: offset.value)
    }
}

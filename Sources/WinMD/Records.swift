public struct Module: Record {
    public var generation: UInt16
    public var name: HeapOffset<StringHeap>
    public var mvid: HeapOffset<GuidHeap>
    public var encId: HeapOffset<GuidHeap>
    public var encBaseId: HeapOffset<GuidHeap>

    public static var tableIndex: TableIndex { .module }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.generation)
            .addHeapOffset(\.name)
            .addHeapOffset(\.mvid)
            .addHeapOffset(\.encId)
            .addHeapOffset(\.encBaseId)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            generation: reader.readConstant(),
            name: reader.readHeapOffset(),
            mvid: reader.readHeapOffset(),
            encId: reader.readHeapOffset(),
            encBaseId: reader.readHeapOffset(last: true))
    }
}

public struct TypeRef: Record {
    var resolutionScope: ResolutionScope
    var typeName: HeapOffset<StringHeap>
    var typeNamespace: HeapOffset<StringHeap>

    public static var tableIndex: TableIndex { .typeRef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addCodedIndex(\.resolutionScope)
            .addHeapOffset(\.typeName)
            .addHeapOffset(\.typeNamespace)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            resolutionScope: reader.readConstant(),
            typeName: reader.readHeapOffset(),
            typeNamespace: reader.readHeapOffset(last: true))
    }
}

public struct TypeDef: Record {
    public var flags: TypeAttributes
    public var typeName: HeapOffset<StringHeap>
    public var typeNamespace: HeapOffset<StringHeap>
    public var extends: TypeDefOrRef
    public var fieldList: RowIndex<Field>
    public var methodList: RowIndex<MethodDef>

    public static var tableIndex: TableIndex { .typeDef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.flags)
            .addHeapOffset(\.typeName)
            .addHeapOffset(\.typeNamespace)
            .addCodedIndex(\.extends)
            .addRowIndex(\.fieldList)
            .addRowIndex(\.methodList)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            flags: reader.readConstant(),
            typeName: reader.readHeapOffset(),
            typeNamespace: reader.readHeapOffset(),
            extends: reader.readCodedIndex(),
            fieldList: reader.readRowIndex(),
            methodList: reader.readRowIndex(last: true))
    }
}

public struct Field: Record {
    public var flags: FieldAttributes
    public var name: HeapOffset<StringHeap>
    public var signature: HeapOffset<BlobHeap>

    public static var tableIndex: TableIndex { .field }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.flags)
            .addHeapOffset(\.name)
            .addHeapOffset(\.signature)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            flags: reader.readConstant(),
            name: reader.readHeapOffset(),
            signature: reader.readHeapOffset(last: true))
    }
}

public struct MethodDef: Record {
    public var rva: UInt32
    public var implFlags: MethodImplAttributes
    public var flags: MethodAttributes
    public var name: HeapOffset<StringHeap>
    public var signature: HeapOffset<BlobHeap>
    // public var paramList: TableRowRef<Param>?

    public static var tableIndex: TableIndex { .methodDef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.rva)
            .addConstant(\.implFlags)
            .addConstant(\.flags)
            .addHeapOffset(\.name)
            .addHeapOffset(\.signature)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            rva: reader.readConstant(),
            implFlags: reader.readConstant(),
            flags: reader.readConstant(),
            name: reader.readHeapOffset(),
            signature: reader.readHeapOffset(last: true))
    }
}

public struct Assembly: Record {
    public var hashAlgId: AssemblyHashAlgorithm
    public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    public var flags: AssemblyFlags
    public var publicKey: HeapOffset<BlobHeap>
    public var name: HeapOffset<StringHeap>
    public var culture: HeapOffset<StringHeap>

    public static var tableIndex: TableIndex { .assembly }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.hashAlgId)
            .addConstant(\.majorVersion)
            .addConstant(\.minorVersion)
            .addConstant(\.buildNumber)
            .addConstant(\.revisionNumber)
            .addConstant(\.flags)
            .addHeapOffset(\.publicKey)
            .addHeapOffset(\.name)
            .addHeapOffset(\.culture)
            .size
    }
    
    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            hashAlgId: reader.readConstant(),
            majorVersion: reader.readConstant(),
            minorVersion: reader.readConstant(),
            buildNumber: reader.readConstant(),
            revisionNumber: reader.readConstant(),
            flags: reader.readConstant(),
            publicKey: reader.readHeapOffset(),
            name: reader.readHeapOffset(),
            culture: reader.readHeapOffset(last: true))
    }
}

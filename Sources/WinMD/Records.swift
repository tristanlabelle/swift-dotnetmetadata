public struct Assembly: Record {
    public var hashAlgId: AssemblyHashAlgorithm
    public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    public var flags: AssemblyFlags
    public var publicKey: HeapEntry<BlobHeap>
    public var name: HeapEntry<StringHeap>
    public var culture: HeapEntry<StringHeap>

    public static var tableIndex: TableIndex { .assembly }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.hashAlgId)
            .addConstant(\.majorVersion)
            .addConstant(\.minorVersion)
            .addConstant(\.buildNumber)
            .addConstant(\.revisionNumber)
            .addConstant(\.flags)
            .addHeapEntry(\.publicKey)
            .addHeapEntry(\.name)
            .addHeapEntry(\.culture)
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
            publicKey: reader.readHeapEntry(),
            name: reader.readHeapEntry(),
            culture: reader.readHeapEntry(last: true))
    }
}

public struct Constant: Record {
    public var type: UInt16
    public var parent: HasConstant
    public var value: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .constant }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.type)
            .addCodedIndex(\.parent)
            .addHeapEntry(\.value)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            type: reader.readConstant(),
            parent: reader.readCodedIndex(),
            value: reader.readHeapEntry(last: true))
    }
}

public struct CustomAttribute: Record {
    public var parent: HasCustomAttribute
    public var type: CustomAttributeType
    public var value: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .customAttribute }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addCodedIndex(\.parent)
            .addCodedIndex(\.type)
            .addHeapEntry(\.value)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            parent: reader.readCodedIndex(),
            type: reader.readCodedIndex(),
            value: reader.readHeapEntry(last: true))
    }
}

public struct Event: Record {
    public var eventFlags: EventAttributes
    public var name: HeapEntry<StringHeap>
    public var eventType: TypeDefOrRef

    public static var tableIndex: TableIndex { .event }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.eventFlags)
            .addHeapEntry(\.name)
            .addCodedIndex(\.eventType)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            eventFlags: reader.readConstant(),
            name: reader.readHeapEntry(),
            eventType: reader.readCodedIndex(last: true))
    }
}

public struct EventMap: Record {
    public var parent: TableRow<TypeDef>
    public var eventList: TableRow<Event>

    public static var tableIndex: TableIndex { .eventMap }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addTableRow(\.parent)
            .addTableRow(\.eventList)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            parent: reader.readTableRow(),
            eventList: reader.readTableRow(last: true))
    }
}

public struct Field: Record {
    public var flags: FieldAttributes
    public var name: HeapEntry<StringHeap>
    public var signature: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .field }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.flags)
            .addHeapEntry(\.name)
            .addHeapEntry(\.signature)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            flags: reader.readConstant(),
            name: reader.readHeapEntry(),
            signature: reader.readHeapEntry(last: true))
    }
}

public struct InterfaceImpl: Record {
    public var `class`: TableRow<TypeDef>
    public var interface: TypeDefOrRef

    public static var tableIndex: TableIndex { .interfaceImpl }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addTableRow(\.`class`)
            .addCodedIndex(\.interface)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            class: reader.readTableRow(),
            interface: reader.readCodedIndex(last: true))
    }
}

public struct MemberRef: Record {
    public var `class`: MemberRefParent
    public var name: HeapEntry<StringHeap>
    public var signature: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .memberRef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addCodedIndex(\.`class`)
            .addHeapEntry(\.name)
            .addHeapEntry(\.signature)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            class: reader.readCodedIndex(),
            name: reader.readHeapEntry(),
            signature: reader.readHeapEntry(last: true))
    }
}

public struct MethodDef: Record {
    public var rva: UInt32
    public var implFlags: MethodImplAttributes
    public var flags: MethodAttributes
    public var name: HeapEntry<StringHeap>
    public var signature: HeapEntry<BlobHeap>
    public var paramList: TableRow<Param>

    public static var tableIndex: TableIndex { .methodDef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.rva)
            .addConstant(\.implFlags)
            .addConstant(\.flags)
            .addHeapEntry(\.name)
            .addHeapEntry(\.signature)
            .addTableRow(\.paramList)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            rva: reader.readConstant(),
            implFlags: reader.readConstant(),
            flags: reader.readConstant(),
            name: reader.readHeapEntry(),
            signature: reader.readHeapEntry(),
            paramList: reader.readTableRow(last: true))
    }
}

public struct MethodImpl: Record {
    public var `class`: TableRow<TypeDef>
    public var methodBody: MethodDefOrRef
    public var methodDeclaration: MethodDefOrRef

    public static var tableIndex: TableIndex { .methodImpl }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addTableRow(\.`class`)
            .addCodedIndex(\.methodBody)
            .addCodedIndex(\.methodDeclaration)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            class: reader.readTableRow(),
            methodBody: reader.readCodedIndex(),
            methodDeclaration: reader.readCodedIndex(last: true))
    }
}

public struct MethodSemantics: Record {
    public var semantics: MethodSemanticsAttributes
    public var method: TableRow<MethodDef>
    public var association: HasSemantics

    public static var tableIndex: TableIndex { .methodSemantics }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.semantics)
            .addTableRow(\.method)
            .addCodedIndex(\.association)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            semantics: reader.readConstant(),
            method: reader.readTableRow(),
            association: reader.readCodedIndex(last: true))
    }
}

public struct Module: Record {
    public var generation: UInt16
    public var name: HeapEntry<StringHeap>
    public var mvid: HeapEntry<GuidHeap>
    public var encId: HeapEntry<GuidHeap>
    public var encBaseId: HeapEntry<GuidHeap>

    public static var tableIndex: TableIndex { .module }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.generation)
            .addHeapEntry(\.name)
            .addHeapEntry(\.mvid)
            .addHeapEntry(\.encId)
            .addHeapEntry(\.encBaseId)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            generation: reader.readConstant(),
            name: reader.readHeapEntry(),
            mvid: reader.readHeapEntry(),
            encId: reader.readHeapEntry(),
            encBaseId: reader.readHeapEntry(last: true))
    }
}

public struct Param: Record {
    public var flags: ParamAttributes
    public var sequence: UInt16
    public var name: HeapEntry<StringHeap>

    public static var tableIndex: TableIndex { .param }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.flags)
            .addConstant(\.sequence)
            .addHeapEntry(\.name)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            flags: reader.readConstant(),
            sequence: reader.readConstant(),
            name: reader.readHeapEntry(last: true))
    }
}

public struct Property: Record {
    public var flags: PropertyAttributes
    public var name: HeapEntry<StringHeap>
    public var type: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .property }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.flags)
            .addHeapEntry(\.name)
            .addHeapEntry(\.type)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            flags: reader.readConstant(),
            name: reader.readHeapEntry(),
            type: reader.readHeapEntry(last: true))
    }
}

public struct PropertyMap: Record {
    public var parent: TableRow<TypeDef>
    public var propertyList: TableRow<Property>

    public static var tableIndex: TableIndex { .propertyMap }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addTableRow(\.parent)
            .addTableRow(\.propertyList)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            parent: reader.readTableRow(),
            propertyList: reader.readTableRow(last: true))
    }
}

public struct TypeDef: Record {
    public var flags: TypeAttributes
    public var typeName: HeapEntry<StringHeap>
    public var typeNamespace: HeapEntry<StringHeap>
    public var extends: TypeDefOrRef
    public var fieldList: TableRow<Field>
    public var methodList: TableRow<MethodDef>

    public static var tableIndex: TableIndex { .typeDef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addConstant(\.flags)
            .addHeapEntry(\.typeName)
            .addHeapEntry(\.typeNamespace)
            .addCodedIndex(\.extends)
            .addTableRow(\.fieldList)
            .addTableRow(\.methodList)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            flags: reader.readConstant(),
            typeName: reader.readHeapEntry(),
            typeNamespace: reader.readHeapEntry(),
            extends: reader.readCodedIndex(),
            fieldList: reader.readTableRow(),
            methodList: reader.readTableRow(last: true))
    }
}

public struct TypeRef: Record {
    var resolutionScope: ResolutionScope
    var typeName: HeapEntry<StringHeap>
    var typeNamespace: HeapEntry<StringHeap>

    public static var tableIndex: TableIndex { .typeRef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        RowSizer<Self>(dimensions: dimensions)
            .addCodedIndex(\.resolutionScope)
            .addHeapEntry(\.typeName)
            .addHeapEntry(\.typeNamespace)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = ColumnReader(buffer: buffer, dimensions: dimensions)
        return Self(
            resolutionScope: reader.readConstant(),
            typeName: reader.readHeapEntry(),
            typeNamespace: reader.readHeapEntry(last: true))
    }
}
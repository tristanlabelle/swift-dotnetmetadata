public protocol TableRow {
    static var tableIndex: TableIndex { get }
    static func getSize(dimensions: Database.Dimensions) -> Int
    static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self
}

public struct Assembly: TableRow {
    public var hashAlgId: AssemblyHashAlgorithm
    public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    public var flags: AssemblyFlags
    public var publicKey: HeapEntry<BlobHeap>
    public var name: HeapEntry<StringHeap>
    public var culture: HeapEntry<StringHeap>

    public static var tableIndex: TableIndex { .assembly }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.hashAlgId)
            .addingConstant(\.majorVersion)
            .addingConstant(\.minorVersion)
            .addingConstant(\.buildNumber)
            .addingConstant(\.revisionNumber)
            .addingConstant(\.flags)
            .addingHeapEntry(\.publicKey)
            .addingHeapEntry(\.name)
            .addingHeapEntry(\.culture)
            .size
    }
    
    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
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

public struct AssemblyRef: TableRow {
    public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    public var flags: AssemblyFlags
    public var publicKeyOrToken: HeapEntry<BlobHeap>
    public var name: HeapEntry<StringHeap>
    public var culture: HeapEntry<StringHeap>
    public var hashValue: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .assemblyRef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.majorVersion)
            .addingConstant(\.minorVersion)
            .addingConstant(\.buildNumber)
            .addingConstant(\.revisionNumber)
            .addingConstant(\.flags)
            .addingHeapEntry(\.publicKeyOrToken)
            .addingHeapEntry(\.name)
            .addingHeapEntry(\.culture)
            .addingHeapEntry(\.hashValue)
            .size
    }
    
    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            majorVersion: reader.readConstant(),
            minorVersion: reader.readConstant(),
            buildNumber: reader.readConstant(),
            revisionNumber: reader.readConstant(),
            flags: reader.readConstant(),
            publicKeyOrToken: reader.readHeapEntry(),
            name: reader.readHeapEntry(),
            culture: reader.readHeapEntry(),
            hashValue: reader.readHeapEntry(last: true))
    }
}

public struct Constant: TableRow {
    public var type: UInt16
    public var parent: HasConstant
    public var value: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .constant }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.type)
            .addingCodedIndex(\.parent)
            .addingHeapEntry(\.value)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            type: reader.readConstant(),
            parent: reader.readCodedIndex(),
            value: reader.readHeapEntry(last: true))
    }
}

public struct CustomAttribute: TableRow {
    public var parent: HasCustomAttribute
    public var type: CustomAttributeType
    public var value: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .customAttribute }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingCodedIndex(\.parent)
            .addingCodedIndex(\.type)
            .addingHeapEntry(\.value)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            parent: reader.readCodedIndex(),
            type: reader.readCodedIndex(),
            value: reader.readHeapEntry(last: true))
    }
}

public struct Event: TableRow {
    public var eventFlags: EventAttributes
    public var name: HeapEntry<StringHeap>
    public var eventType: TypeDefOrRef

    public static var tableIndex: TableIndex { .event }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.eventFlags)
            .addingHeapEntry(\.name)
            .addingCodedIndex(\.eventType)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            eventFlags: reader.readConstant(),
            name: reader.readHeapEntry(),
            eventType: reader.readCodedIndex(last: true))
    }
}

public struct EventMap: TableRow {
    public var parent: TableRowIndex<TypeDef>
    public var eventList: TableRowIndex<Event>

    public static var tableIndex: TableIndex { .eventMap }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingTableRowIndex(\.parent)
            .addingTableRowIndex(\.eventList)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            parent: reader.readTableRowIndex(),
            eventList: reader.readTableRowIndex(last: true))
    }
}

public struct Field: TableRow {
    public var flags: FieldAttributes
    public var name: HeapEntry<StringHeap>
    public var signature: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .field }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.flags)
            .addingHeapEntry(\.name)
            .addingHeapEntry(\.signature)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            flags: reader.readConstant(),
            name: reader.readHeapEntry(),
            signature: reader.readHeapEntry(last: true))
    }
}

public struct GenericParam: TableRow {
    public var number: UInt16
    public var flags: GenericParamAttributes
    public var owner: TypeOrMethodDef
    public var name: HeapEntry<StringHeap>

    public static var tableIndex: TableIndex { .module }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.number)
            .addingConstant(\.flags)
            .addingCodedIndex(\.owner)
            .addingHeapEntry(\.name)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            number: reader.readConstant(),
            flags: reader.readConstant(),
            owner: reader.readCodedIndex(),
            name: reader.readHeapEntry(last: true))
    }
}

public struct InterfaceImpl: TableRow {
    public var `class`: TableRowIndex<TypeDef>
    public var interface: TypeDefOrRef

    public static var tableIndex: TableIndex { .interfaceImpl }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingTableRowIndex(\.`class`)
            .addingCodedIndex(\.interface)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            class: reader.readTableRowIndex(),
            interface: reader.readCodedIndex(last: true))
    }
}

public struct MemberRef: TableRow {
    public var `class`: MemberRefParent
    public var name: HeapEntry<StringHeap>
    public var signature: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .memberRef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingCodedIndex(\.`class`)
            .addingHeapEntry(\.name)
            .addingHeapEntry(\.signature)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            class: reader.readCodedIndex(),
            name: reader.readHeapEntry(),
            signature: reader.readHeapEntry(last: true))
    }
}

public struct MethodDef: TableRow {
    public var rva: UInt32
    public var implFlags: MethodImplAttributes
    public var flags: MethodAttributes
    public var name: HeapEntry<StringHeap>
    public var signature: HeapEntry<BlobHeap>
    public var paramList: TableRowIndex<Param>

    public static var tableIndex: TableIndex { .methodDef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.rva)
            .addingConstant(\.implFlags)
            .addingConstant(\.flags)
            .addingHeapEntry(\.name)
            .addingHeapEntry(\.signature)
            .addingTableRowIndex(\.paramList)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            rva: reader.readConstant(),
            implFlags: reader.readConstant(),
            flags: reader.readConstant(),
            name: reader.readHeapEntry(),
            signature: reader.readHeapEntry(),
            paramList: reader.readTableRowIndex(last: true))
    }
}

public struct MethodImpl: TableRow {
    public var `class`: TableRowIndex<TypeDef>
    public var methodBody: MethodDefOrRef
    public var methodDeclaration: MethodDefOrRef

    public static var tableIndex: TableIndex { .methodImpl }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingTableRowIndex(\.`class`)
            .addingCodedIndex(\.methodBody)
            .addingCodedIndex(\.methodDeclaration)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            class: reader.readTableRowIndex(),
            methodBody: reader.readCodedIndex(),
            methodDeclaration: reader.readCodedIndex(last: true))
    }
}

public struct MethodSemantics: TableRow {
    public var semantics: MethodSemanticsAttributes
    public var method: TableRowIndex<MethodDef>
    public var association: HasSemantics

    public static var tableIndex: TableIndex { .methodSemantics }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.semantics)
            .addingTableRowIndex(\.method)
            .addingCodedIndex(\.association)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            semantics: reader.readConstant(),
            method: reader.readTableRowIndex(),
            association: reader.readCodedIndex(last: true))
    }
}

public struct Module: TableRow {
    public var generation: UInt16
    public var name: HeapEntry<StringHeap>
    public var mvid: HeapEntry<GuidHeap>
    public var encId: HeapEntry<GuidHeap>
    public var encBaseId: HeapEntry<GuidHeap>

    public static var tableIndex: TableIndex { .module }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.generation)
            .addingHeapEntry(\.name)
            .addingHeapEntry(\.mvid)
            .addingHeapEntry(\.encId)
            .addingHeapEntry(\.encBaseId)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            generation: reader.readConstant(),
            name: reader.readHeapEntry(),
            mvid: reader.readHeapEntry(),
            encId: reader.readHeapEntry(),
            encBaseId: reader.readHeapEntry(last: true))
    }
}

public struct Param: TableRow {
    public var flags: ParamAttributes
    public var sequence: UInt16
    public var name: HeapEntry<StringHeap>

    public static var tableIndex: TableIndex { .param }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.flags)
            .addingConstant(\.sequence)
            .addingHeapEntry(\.name)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            flags: reader.readConstant(),
            sequence: reader.readConstant(),
            name: reader.readHeapEntry(last: true))
    }
}

public struct Property: TableRow {
    public var flags: PropertyAttributes
    public var name: HeapEntry<StringHeap>
    public var type: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .property }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.flags)
            .addingHeapEntry(\.name)
            .addingHeapEntry(\.type)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            flags: reader.readConstant(),
            name: reader.readHeapEntry(),
            type: reader.readHeapEntry(last: true))
    }
}

public struct PropertyMap: TableRow {
    public var parent: TableRowIndex<TypeDef>
    public var propertyList: TableRowIndex<Property>

    public static var tableIndex: TableIndex { .propertyMap }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingTableRowIndex(\.parent)
            .addingTableRowIndex(\.propertyList)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            parent: reader.readTableRowIndex(),
            propertyList: reader.readTableRowIndex(last: true))
    }
}

public struct TypeDef: TableRow {
    public var flags: TypeAttributes
    public var typeName: HeapEntry<StringHeap>
    public var typeNamespace: HeapEntry<StringHeap>
    public var extends: TypeDefOrRef
    public var fieldList: TableRowIndex<Field>
    public var methodList: TableRowIndex<MethodDef>

    public static var tableIndex: TableIndex { .typeDef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.flags)
            .addingHeapEntry(\.typeName)
            .addingHeapEntry(\.typeNamespace)
            .addingCodedIndex(\.extends)
            .addingTableRowIndex(\.fieldList)
            .addingTableRowIndex(\.methodList)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            flags: reader.readConstant(),
            typeName: reader.readHeapEntry(),
            typeNamespace: reader.readHeapEntry(),
            extends: reader.readCodedIndex(),
            fieldList: reader.readTableRowIndex(),
            methodList: reader.readTableRowIndex(last: true))
    }
}

public struct TypeRef: TableRow {
    var resolutionScope: ResolutionScope
    var typeName: HeapEntry<StringHeap>
    var typeNamespace: HeapEntry<StringHeap>

    public static var tableIndex: TableIndex { .typeRef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingCodedIndex(\.resolutionScope)
            .addingHeapEntry(\.typeName)
            .addingHeapEntry(\.typeNamespace)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            resolutionScope: reader.readConstant(),
            typeName: reader.readHeapEntry(),
            typeNamespace: reader.readHeapEntry(last: true))
    }
}


public struct TypeSpec: TableRow {
    public var signature: HeapEntry<BlobHeap>

    public static var tableIndex: TableIndex { .typeSpec }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingHeapEntry(\.signature)
            .size
    }

    public static func read(buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) -> Self {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        return Self(
            signature: reader.readHeapEntry(last: true))
    }
}
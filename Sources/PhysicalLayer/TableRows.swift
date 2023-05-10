/// A row in a metadata table
/// The size of rows isn't constant because the size of column which index
/// into heaps or other metadata tables depends on the size of these.
public protocol TableRow {
    static var tableIndex: TableIndex { get }
    static func getSize(dimensions: Database.Dimensions) -> Int
    init(reading: UnsafeRawBufferPointer, dimensions: Database.Dimensions)
}

public struct Assembly {
    public var hashAlgId: AssemblyHashAlgorithm
    public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    public var flags: AssemblyFlags
    public var publicKey: HeapEntry<BlobHeap>
    public var name: HeapEntry<StringHeap>
    public var culture: HeapEntry<StringHeap>
}

extension Assembly: TableRow {
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

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
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

public struct AssemblyRef {
    public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    public var flags: AssemblyFlags
    public var publicKeyOrToken: HeapEntry<BlobHeap>
    public var name: HeapEntry<StringHeap>
    public var culture: HeapEntry<StringHeap>
    public var hashValue: HeapEntry<BlobHeap>
}

extension AssemblyRef: TableRow {
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
    
    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
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

public struct Constant {
    public var type: UInt16
    public var parent: HasConstant
    public var value: HeapEntry<BlobHeap>
}

extension Constant: TableRow {
    public static var tableIndex: TableIndex { .constant }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.type)
            .addingCodedIndex(\.parent)
            .addingHeapEntry(\.value)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            type: reader.readConstant(),
            parent: reader.readCodedIndex(),
            value: reader.readHeapEntry(last: true))
    }
}

public struct CustomAttribute {
    public var parent: HasCustomAttribute
    public var type: CustomAttributeType
    public var value: HeapEntry<BlobHeap>
}

extension CustomAttribute: TableRow {
    public static var tableIndex: TableIndex { .customAttribute }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingCodedIndex(\.parent)
            .addingCodedIndex(\.type)
            .addingHeapEntry(\.value)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            parent: reader.readCodedIndex(),
            type: reader.readCodedIndex(),
            value: reader.readHeapEntry(last: true))
    }
}

public struct Event {
    public var eventFlags: EventAttributes
    public var name: HeapEntry<StringHeap>
    public var eventType: TypeDefOrRef
}

extension Event: TableRow {
    public static var tableIndex: TableIndex { .event }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.eventFlags)
            .addingHeapEntry(\.name)
            .addingCodedIndex(\.eventType)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            eventFlags: reader.readConstant(),
            name: reader.readHeapEntry(),
            eventType: reader.readCodedIndex(last: true))
    }
}

public struct EventMap {
    public var parent: TableRowIndex<TypeDef>
    public var eventList: TableRowIndex<Event>
}

extension EventMap: TableRow {
    public static var tableIndex: TableIndex { .eventMap }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingTableRowIndex(\.parent)
            .addingTableRowIndex(\.eventList)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            parent: reader.readTableRowIndex(),
            eventList: reader.readTableRowIndex(last: true))
    }
}

public struct Field {
    public var flags: FieldAttributes
    public var name: HeapEntry<StringHeap>
    public var signature: HeapEntry<BlobHeap>
}

extension Field: TableRow {
    public static var tableIndex: TableIndex { .field }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.flags)
            .addingHeapEntry(\.name)
            .addingHeapEntry(\.signature)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            flags: reader.readConstant(),
            name: reader.readHeapEntry(),
            signature: reader.readHeapEntry(last: true))
    }
}

public struct GenericParam {
    public var number: UInt16
    public var flags: GenericParamAttributes
    public var owner: TypeOrMethodDef
    public var name: HeapEntry<StringHeap>
}

extension GenericParam: TableRow {
    public static var tableIndex: TableIndex { .module }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.number)
            .addingConstant(\.flags)
            .addingCodedIndex(\.owner)
            .addingHeapEntry(\.name)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            number: reader.readConstant(),
            flags: reader.readConstant(),
            owner: reader.readCodedIndex(),
            name: reader.readHeapEntry(last: true))
    }
}

public struct InterfaceImpl {
    public var `class`: TableRowIndex<TypeDef>
    public var interface: TypeDefOrRef
}

extension InterfaceImpl: TableRow {
    public static var tableIndex: TableIndex { .interfaceImpl }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingTableRowIndex(\.`class`)
            .addingCodedIndex(\.interface)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            class: reader.readTableRowIndex(),
            interface: reader.readCodedIndex(last: true))
    }
}

public struct MemberRef {
    public var `class`: MemberRefParent
    public var name: HeapEntry<StringHeap>
    public var signature: HeapEntry<BlobHeap>
}

extension MemberRef: TableRow {
    public static var tableIndex: TableIndex { .memberRef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingCodedIndex(\.`class`)
            .addingHeapEntry(\.name)
            .addingHeapEntry(\.signature)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            class: reader.readCodedIndex(),
            name: reader.readHeapEntry(),
            signature: reader.readHeapEntry(last: true))
    }
}

public struct MethodDef {
    public var rva: UInt32
    public var implFlags: MethodImplAttributes
    public var flags: MethodAttributes
    public var name: HeapEntry<StringHeap>
    public var signature: HeapEntry<BlobHeap>
    public var paramList: TableRowIndex<Param>
}

extension MethodDef: TableRow {
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

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            rva: reader.readConstant(),
            implFlags: reader.readConstant(),
            flags: reader.readConstant(),
            name: reader.readHeapEntry(),
            signature: reader.readHeapEntry(),
            paramList: reader.readTableRowIndex(last: true))
    }
}

public struct MethodImpl {
    public var `class`: TableRowIndex<TypeDef>
    public var methodBody: MethodDefOrRef
    public var methodDeclaration: MethodDefOrRef
}

extension MethodImpl: TableRow {
    public static var tableIndex: TableIndex { .methodImpl }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingTableRowIndex(\.`class`)
            .addingCodedIndex(\.methodBody)
            .addingCodedIndex(\.methodDeclaration)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            class: reader.readTableRowIndex(),
            methodBody: reader.readCodedIndex(),
            methodDeclaration: reader.readCodedIndex(last: true))
    }
}

public struct MethodSemantics {
    public var semantics: MethodSemanticsAttributes
    public var method: TableRowIndex<MethodDef>
    public var association: HasSemantics
}

extension MethodSemantics: TableRow {
    public static var tableIndex: TableIndex { .methodSemantics }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.semantics)
            .addingTableRowIndex(\.method)
            .addingCodedIndex(\.association)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            semantics: reader.readConstant(),
            method: reader.readTableRowIndex(),
            association: reader.readCodedIndex(last: true))
    }
}

public struct Module {
    public var generation: UInt16
    public var name: HeapEntry<StringHeap>
    public var mvid: HeapEntry<GuidHeap>
    public var encId: HeapEntry<GuidHeap>
    public var encBaseId: HeapEntry<GuidHeap>
}

extension Module: TableRow {
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

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            generation: reader.readConstant(),
            name: reader.readHeapEntry(),
            mvid: reader.readHeapEntry(),
            encId: reader.readHeapEntry(),
            encBaseId: reader.readHeapEntry(last: true))
    }
}

public struct Param {
    public var flags: ParamAttributes
    public var sequence: UInt16
    public var name: HeapEntry<StringHeap>
}

extension Param: TableRow {
    public static var tableIndex: TableIndex { .param }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.flags)
            .addingConstant(\.sequence)
            .addingHeapEntry(\.name)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            flags: reader.readConstant(),
            sequence: reader.readConstant(),
            name: reader.readHeapEntry(last: true))
    }
}

public struct Property {
    public var flags: PropertyAttributes
    public var name: HeapEntry<StringHeap>
    public var type: HeapEntry<BlobHeap>
}

extension Property: TableRow {
    public static var tableIndex: TableIndex { .property }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingConstant(\.flags)
            .addingHeapEntry(\.name)
            .addingHeapEntry(\.type)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            flags: reader.readConstant(),
            name: reader.readHeapEntry(),
            type: reader.readHeapEntry(last: true))
    }
}

public struct PropertyMap {
    public var parent: TableRowIndex<TypeDef>
    public var propertyList: TableRowIndex<Property>
}

extension PropertyMap: TableRow {
    public static var tableIndex: TableIndex { .propertyMap }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingTableRowIndex(\.parent)
            .addingTableRowIndex(\.propertyList)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            parent: reader.readTableRowIndex(),
            propertyList: reader.readTableRowIndex(last: true))
    }
}

public struct TypeDef {
    public var flags: TypeAttributes
    public var typeName: HeapEntry<StringHeap>
    public var typeNamespace: HeapEntry<StringHeap>
    public var extends: TypeDefOrRef
    public var fieldList: TableRowIndex<Field>
    public var methodList: TableRowIndex<MethodDef>
}

extension TypeDef: TableRow {
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

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            flags: reader.readConstant(),
            typeName: reader.readHeapEntry(),
            typeNamespace: reader.readHeapEntry(),
            extends: reader.readCodedIndex(),
            fieldList: reader.readTableRowIndex(),
            methodList: reader.readTableRowIndex(last: true))
    }
}

public struct TypeRef {
    var resolutionScope: ResolutionScope
    var typeName: HeapEntry<StringHeap>
    var typeNamespace: HeapEntry<StringHeap>
}

extension TypeRef: TableRow {
    public static var tableIndex: TableIndex { .typeRef }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingCodedIndex(\.resolutionScope)
            .addingHeapEntry(\.typeName)
            .addingHeapEntry(\.typeNamespace)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            resolutionScope: reader.readConstant(),
            typeName: reader.readHeapEntry(),
            typeNamespace: reader.readHeapEntry(last: true))
    }
}


public struct TypeSpec {
    public var signature: HeapEntry<BlobHeap>
}

extension TypeSpec: TableRow {
    public static var tableIndex: TableIndex { .typeSpec }

    public static func getSize(dimensions: Database.Dimensions) -> Int {
        TableRowSizer<Self>(dimensions: dimensions)
            .addingHeapEntry(\.signature)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, dimensions: Database.Dimensions) {
        var reader = TableRowReader(buffer: buffer, dimensions: dimensions)
        self.init(
            signature: reader.readHeapEntry(last: true))
    }
}
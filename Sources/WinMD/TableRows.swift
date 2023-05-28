/// A row in a metadata table
/// The size of rows isn't constant because the size of columns which index
/// into heaps or other metadata tables depends on the size of these heaps/tables.
public protocol TableRow {
    static var tableIndex: TableIndex { get }
    static func getSize(sizes: TableSizes) -> Int
    init(reading: UnsafeRawBufferPointer, sizes: TableSizes)
}

public protocol KeyedTableRow: TableRow {
    associatedtype PrimaryKey: Comparable
    var primaryKey: PrimaryKey { get }
}

public protocol DoublyKeyedTableRow: KeyedTableRow {
    associatedtype SecondaryKey: Comparable
    var secondaryKey: SecondaryKey { get }
}

public struct Assembly {
    public var hashAlgId: AssemblyHashAlgorithm
    public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    public var flags: AssemblyFlags
    public var publicKey: HeapOffset<BlobHeap>
    public var name: HeapOffset<StringHeap>
    public var culture: HeapOffset<StringHeap>
}

extension Assembly: TableRow {
    public static var tableIndex: TableIndex { .assembly }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.hashAlgId)
            .addingConstant(\.majorVersion)
            .addingConstant(\.minorVersion)
            .addingConstant(\.buildNumber)
            .addingConstant(\.revisionNumber)
            .addingConstant(\.flags)
            .addingHeapOffset(\.publicKey)
            .addingHeapOffset(\.name)
            .addingHeapOffset(\.culture)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
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

public struct AssemblyRef {
    public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    public var flags: AssemblyFlags
    public var publicKeyOrToken: HeapOffset<BlobHeap>
    public var name: HeapOffset<StringHeap>
    public var culture: HeapOffset<StringHeap>
    public var hashValue: HeapOffset<BlobHeap>
}

extension AssemblyRef: TableRow {
    public static var tableIndex: TableIndex { .assemblyRef }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.majorVersion)
            .addingConstant(\.minorVersion)
            .addingConstant(\.buildNumber)
            .addingConstant(\.revisionNumber)
            .addingConstant(\.flags)
            .addingHeapOffset(\.publicKeyOrToken)
            .addingHeapOffset(\.name)
            .addingHeapOffset(\.culture)
            .addingHeapOffset(\.hashValue)
            .size
    }
    
    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            majorVersion: reader.readConstant(),
            minorVersion: reader.readConstant(),
            buildNumber: reader.readConstant(),
            revisionNumber: reader.readConstant(),
            flags: reader.readConstant(),
            publicKeyOrToken: reader.readHeapOffset(),
            name: reader.readHeapOffset(),
            culture: reader.readHeapOffset(),
            hashValue: reader.readHeapOffset(last: true))
    }
}

public struct Constant {
    public var type: UInt16
    public var parent: HasConstant
    public var value: HeapOffset<BlobHeap>
}

extension Constant: KeyedTableRow {
    public var primaryKey: MetadataToken { parent.metadataToken }

    public static var tableIndex: TableIndex { .constant }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.type)
            .addingCodedIndex(\.parent)
            .addingHeapOffset(\.value)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            type: reader.readConstant(),
            parent: reader.readCodedIndex(),
            value: reader.readHeapOffset(last: true))
    }
}

public struct CustomAttribute {
    public var parent: HasCustomAttribute
    public var type: CustomAttributeType
    public var value: HeapOffset<BlobHeap>
}

extension CustomAttribute: KeyedTableRow {
    public var primaryKey: MetadataToken { parent.metadataToken }

    public static var tableIndex: TableIndex { .customAttribute }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingCodedIndex(\.parent)
            .addingCodedIndex(\.type)
            .addingHeapOffset(\.value)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            parent: reader.readCodedIndex(),
            type: reader.readCodedIndex(),
            value: reader.readHeapOffset(last: true))
    }
}

public struct Event {
    public var eventFlags: EventAttributes
    public var name: HeapOffset<StringHeap>
    public var eventType: TypeDefOrRef
}

extension Event: TableRow {
    public static var tableIndex: TableIndex { .event }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.eventFlags)
            .addingHeapOffset(\.name)
            .addingCodedIndex(\.eventType)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            eventFlags: reader.readConstant(),
            name: reader.readHeapOffset(),
            eventType: reader.readCodedIndex(last: true))
    }
}

public struct EventMap {
    public var parent: TableRowIndex<TypeDef>?
    public var eventList: TableRowIndex<Event>?
}

extension EventMap: TableRow {
    public static var tableIndex: TableIndex { .eventMap }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowIndex(\.parent)
            .addingTableRowIndex(\.eventList)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            parent: reader.readTableRowIndex(),
            eventList: reader.readTableRowIndex(last: true))
    }
}

public struct Field {
    public var flags: FieldAttributes
    public var name: HeapOffset<StringHeap>
    public var signature: HeapOffset<BlobHeap>
}

extension Field: TableRow {
    public static var tableIndex: TableIndex { .field }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.flags)
            .addingHeapOffset(\.name)
            .addingHeapOffset(\.signature)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            flags: reader.readConstant(),
            name: reader.readHeapOffset(),
            signature: reader.readHeapOffset(last: true))
    }
}

public struct GenericParam {
    public var number: UInt16
    public var flags: GenericParamAttributes
    public var owner: TypeOrMethodDef
    public var name: HeapOffset<StringHeap>
}

extension GenericParam: DoublyKeyedTableRow {
    public var primaryKey: MetadataToken { owner.metadataToken }
    public var secondaryKey: UInt16 { number }

    public static var tableIndex: TableIndex { .module }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.number)
            .addingConstant(\.flags)
            .addingCodedIndex(\.owner)
            .addingHeapOffset(\.name)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            number: reader.readConstant(),
            flags: reader.readConstant(),
            owner: reader.readCodedIndex(),
            name: reader.readHeapOffset(last: true))
    }
}

public struct InterfaceImpl {
    public var `class`: TableRowIndex<TypeDef>?
    public var interface: TypeDefOrRef
}

extension InterfaceImpl: DoublyKeyedTableRow {
    public var primaryKey: MetadataToken { .init(`class`) }
    public var secondaryKey: MetadataToken { interface.metadataToken }

    public static var tableIndex: TableIndex { .interfaceImpl }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowIndex(\.`class`)
            .addingCodedIndex(\.interface)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            class: reader.readTableRowIndex(),
            interface: reader.readCodedIndex(last: true))
    }
}

public struct MemberRef {
    public var `class`: MemberRefParent
    public var name: HeapOffset<StringHeap>
    public var signature: HeapOffset<BlobHeap>
}

extension MemberRef: TableRow {
    public static var tableIndex: TableIndex { .memberRef }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingCodedIndex(\.`class`)
            .addingHeapOffset(\.name)
            .addingHeapOffset(\.signature)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            class: reader.readCodedIndex(),
            name: reader.readHeapOffset(),
            signature: reader.readHeapOffset(last: true))
    }
}

public struct MethodDef {
    public var rva: UInt32
    public var implFlags: MethodImplAttributes
    public var flags: MethodAttributes
    public var name: HeapOffset<StringHeap>
    public var signature: HeapOffset<BlobHeap>
    public var paramList: TableRowIndex<Param>?
}

extension MethodDef: TableRow {
    public static var tableIndex: TableIndex { .methodDef }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.rva)
            .addingConstant(\.implFlags)
            .addingConstant(\.flags)
            .addingHeapOffset(\.name)
            .addingHeapOffset(\.signature)
            .addingTableRowIndex(\.paramList)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            rva: reader.readConstant(),
            implFlags: reader.readConstant(),
            flags: reader.readConstant(),
            name: reader.readHeapOffset(),
            signature: reader.readHeapOffset(),
            paramList: reader.readTableRowIndex(last: true))
    }
}

public struct MethodImpl {
    public var `class`: TableRowIndex<TypeDef>?
    public var methodBody: MethodDefOrRef
    public var methodDeclaration: MethodDefOrRef
}

extension MethodImpl: KeyedTableRow {
    public var primaryKey: MetadataToken { .init(`class`) }

    public static var tableIndex: TableIndex { .methodImpl }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowIndex(\.`class`)
            .addingCodedIndex(\.methodBody)
            .addingCodedIndex(\.methodDeclaration)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            class: reader.readTableRowIndex(),
            methodBody: reader.readCodedIndex(),
            methodDeclaration: reader.readCodedIndex(last: true))
    }
}

public struct MethodSemantics {
    public var semantics: MethodSemanticsAttributes
    public var method: TableRowIndex<MethodDef>?
    public var association: HasSemantics
}

extension MethodSemantics: KeyedTableRow {
    public var primaryKey: MetadataToken { association.metadataToken }

    public static var tableIndex: TableIndex { .methodSemantics }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.semantics)
            .addingTableRowIndex(\.method)
            .addingCodedIndex(\.association)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            semantics: reader.readConstant(),
            method: reader.readTableRowIndex(),
            association: reader.readCodedIndex(last: true))
    }
}

public struct Module {
    public var generation: UInt16
    public var name: HeapOffset<StringHeap>
    public var mvid: HeapOffset<GuidHeap>
    public var encId: HeapOffset<GuidHeap>
    public var encBaseId: HeapOffset<GuidHeap>
}

extension Module: TableRow {
    public static var tableIndex: TableIndex { .module }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.generation)
            .addingHeapOffset(\.name)
            .addingHeapOffset(\.mvid)
            .addingHeapOffset(\.encId)
            .addingHeapOffset(\.encBaseId)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            generation: reader.readConstant(),
            name: reader.readHeapOffset(),
            mvid: reader.readHeapOffset(),
            encId: reader.readHeapOffset(),
            encBaseId: reader.readHeapOffset(last: true))
    }
}

public struct Param {
    public var flags: ParamAttributes
    public var sequence: UInt16
    public var name: HeapOffset<StringHeap>
}

extension Param: TableRow {
    public static var tableIndex: TableIndex { .param }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.flags)
            .addingConstant(\.sequence)
            .addingHeapOffset(\.name)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            flags: reader.readConstant(),
            sequence: reader.readConstant(),
            name: reader.readHeapOffset(last: true))
    }
}

public struct Property {
    public var flags: PropertyAttributes
    public var name: HeapOffset<StringHeap>
    public var type: HeapOffset<BlobHeap>
}

extension Property: TableRow {
    public static var tableIndex: TableIndex { .property }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.flags)
            .addingHeapOffset(\.name)
            .addingHeapOffset(\.type)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            flags: reader.readConstant(),
            name: reader.readHeapOffset(),
            type: reader.readHeapOffset(last: true))
    }
}

public struct PropertyMap {
    public var parent: TableRowIndex<TypeDef>?
    public var propertyList: TableRowIndex<Property>?
}

extension PropertyMap: TableRow {
    public static var tableIndex: TableIndex { .propertyMap }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowIndex(\.parent)
            .addingTableRowIndex(\.propertyList)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            parent: reader.readTableRowIndex(),
            propertyList: reader.readTableRowIndex(last: true))
    }
}

public struct TypeDef {
    public var flags: TypeAttributes
    public var typeName: HeapOffset<StringHeap>
    public var typeNamespace: HeapOffset<StringHeap>
    public var extends: TypeDefOrRef
    public var fieldList: TableRowIndex<Field>?
    public var methodList: TableRowIndex<MethodDef>?
}

extension TypeDef: TableRow {
    public static var tableIndex: TableIndex { .typeDef }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.flags)
            .addingHeapOffset(\.typeName)
            .addingHeapOffset(\.typeNamespace)
            .addingCodedIndex(\.extends)
            .addingTableRowIndex(\.fieldList)
            .addingTableRowIndex(\.methodList)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            flags: reader.readConstant(),
            typeName: reader.readHeapOffset(),
            typeNamespace: reader.readHeapOffset(),
            extends: reader.readCodedIndex(),
            fieldList: reader.readTableRowIndex(),
            methodList: reader.readTableRowIndex(last: true))
    }
}

public struct TypeRef {
    var resolutionScope: ResolutionScope
    var typeName: HeapOffset<StringHeap>
    var typeNamespace: HeapOffset<StringHeap>
}

extension TypeRef: TableRow {
    public static var tableIndex: TableIndex { .typeRef }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingCodedIndex(\.resolutionScope)
            .addingHeapOffset(\.typeName)
            .addingHeapOffset(\.typeNamespace)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            resolutionScope: reader.readConstant(),
            typeName: reader.readHeapOffset(),
            typeNamespace: reader.readHeapOffset(last: true))
    }
}


public struct TypeSpec {
    public var signature: HeapOffset<BlobHeap>
}

extension TypeSpec: TableRow {
    public static var tableIndex: TableIndex { .typeSpec }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingHeapOffset(\.signature)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        var reader = TableRowReader(buffer: buffer, sizes: sizes)
        self.init(
            signature: reader.readHeapOffset(last: true))
    }
}
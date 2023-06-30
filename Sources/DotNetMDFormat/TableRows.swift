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

    public var version: AssemblyVersion {
        .init(
            major: majorVersion,
            minor: minorVersion,
            buildNumber: buildNumber,
            revisionNumber: revisionNumber)
    }
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                hashAlgId: $0.readConstant(),
                majorVersion: $0.readConstant(),
                minorVersion: $0.readConstant(),
                buildNumber: $0.readConstant(),
                revisionNumber: $0.readConstant(),
                flags: $0.readConstant(),
                publicKey: $0.readHeapOffset(),
                name: $0.readHeapOffset(),
                culture: $0.readHeapOffset())
        }
    }
}

public struct AssemblyRef {
    public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
    public var flags: AssemblyFlags
    public var publicKeyOrToken: HeapOffset<BlobHeap>
    public var name: HeapOffset<StringHeap>
    public var culture: HeapOffset<StringHeap>
    public var hashValue: HeapOffset<BlobHeap>
    
    public var version: AssemblyVersion {
        .init(
            major: majorVersion,
            minor: minorVersion,
            buildNumber: buildNumber,
            revisionNumber: revisionNumber)
    }
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                majorVersion: $0.readConstant(),
                minorVersion: $0.readConstant(),
                buildNumber: $0.readConstant(),
                revisionNumber: $0.readConstant(),
                flags: $0.readConstant(),
                publicKeyOrToken: $0.readHeapOffset(),
                name: $0.readHeapOffset(),
                culture: $0.readHeapOffset(),
                hashValue: $0.readHeapOffset())
        }
    }
}

public struct ClassLayout {
    public var packingSize: UInt16
    public var classSize: UInt32
    public var parent: Table<TypeDef>.RowIndex?
}

extension ClassLayout: TableRow {
    public static var tableIndex: TableIndex { .classLayout }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.packingSize)
            .addingConstant(\.classSize)
            .addingTableRowIndex(\.parent)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                packingSize: $0.readConstant(),
                classSize: $0.readConstant(),
                parent: $0.readTableRowIndex())
        }
    }
}

public struct Constant {
    public var type: ConstantType
    public var parent: HasConstant
    public var value: HeapOffset<BlobHeap>
}

extension Constant: KeyedTableRow {
    public var primaryKey: MetadataToken { parent.metadataToken }

    public static var tableIndex: TableIndex { .constant }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.type)
            .addingPaddingByte()
            .addingCodedIndex(\.parent)
            .addingHeapOffset(\.value)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            let type: ConstantType = $0.readConstant()
            let _: UInt8 = $0.readConstant()
            return Self(
                type: type,
                parent: $0.readCodedIndex(),
                value: $0.readHeapOffset())
        }
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                parent: $0.readCodedIndex(),
                type: $0.readCodedIndex(),
                value: $0.readHeapOffset())
        }
    }
}

public struct DeclSecurity {
    public var action: UInt16
    public var parent: HasDeclSecurity
    public var permissionSet: HeapOffset<BlobHeap>
}

extension DeclSecurity: TableRow {
    public static var tableIndex: TableIndex { .declSecurity }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.action)
            .addingCodedIndex(\.parent)
            .addingHeapOffset(\.permissionSet)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                action: $0.readConstant(),
                parent: $0.readCodedIndex(),
                permissionSet: $0.readHeapOffset())
        }
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                eventFlags: $0.readConstant(),
                name: $0.readHeapOffset(),
                eventType: $0.readCodedIndex())
        }
    }
}

public struct EventMap {
    public var parent: Table<TypeDef>.RowIndex?
    public var eventList: Table<Event>.RowIndex?
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                parent: $0.readTableRowIndex(),
                eventList: $0.readTableRowIndex())
        }
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                flags: $0.readConstant(),
                name: $0.readHeapOffset(),
                signature: $0.readHeapOffset())
        }
    }
}

public struct FieldLayout {
    public var offset: UInt32
    public var field: Table<Field>.RowIndex?
}

extension FieldLayout: TableRow {
    public static var tableIndex: TableIndex { .fieldLayout }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.offset)
            .addingTableRowIndex(\.field)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                offset: $0.readConstant(),
                field: $0.readTableRowIndex())
        }
    }
}

public struct FieldMarshal {
    public var parent: HasFieldMarshal
    public var nativeType: HeapOffset<BlobHeap>
}

extension FieldMarshal: TableRow {
    public static var tableIndex: TableIndex { .fieldMarshal }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingCodedIndex(\.parent)
            .addingHeapOffset(\.nativeType)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                parent: $0.readCodedIndex(),
                nativeType: $0.readHeapOffset())
        }
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

    public static var tableIndex: TableIndex { .genericParam }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.number)
            .addingConstant(\.flags)
            .addingCodedIndex(\.owner)
            .addingHeapOffset(\.name)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                number: $0.readConstant(),
                flags: $0.readConstant(),
                owner: $0.readCodedIndex(),
                name: $0.readHeapOffset())
        }
    }
}

public struct GenericParamConstraint {
    public var owner: Table<GenericParam>.RowIndex?
    public var constraint: TypeDefOrRef
}

extension GenericParamConstraint: KeyedTableRow {
    public var primaryKey: MetadataToken { .init(owner) }

    public static var tableIndex: TableIndex { .genericParamConstraint }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowIndex(\.owner)
            .addingCodedIndex(\.constraint)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                owner: $0.readTableRowIndex(),
                constraint: $0.readCodedIndex())
        }
    }
}

public struct InterfaceImpl {
    public var `class`: Table<TypeDef>.RowIndex?
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                class: $0.readTableRowIndex(),
                interface: $0.readCodedIndex())
        }
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                class: $0.readCodedIndex(),
                name: $0.readHeapOffset(),
                signature: $0.readHeapOffset())
        }
    }
}

public struct MethodDef {
    public var rva: UInt32
    public var implFlags: MethodImplAttributes
    public var flags: MethodAttributes
    public var name: HeapOffset<StringHeap>
    public var signature: HeapOffset<BlobHeap>
    public var paramList: Table<Param>.RowIndex?
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                rva: $0.readConstant(),
                implFlags: $0.readConstant(),
                flags: $0.readConstant(),
                name: $0.readHeapOffset(),
                signature: $0.readHeapOffset(),
                paramList: $0.readTableRowIndex())
        }
    }
}

public struct MethodImpl {
    public var `class`: Table<TypeDef>.RowIndex?
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                class: $0.readTableRowIndex(),
                methodBody: $0.readCodedIndex(),
                methodDeclaration: $0.readCodedIndex())
        }
    }
}

public struct MethodSemantics {
    public var semantics: MethodSemanticsAttributes
    public var method: Table<MethodDef>.RowIndex?
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                semantics: $0.readConstant(),
                method: $0.readTableRowIndex(),
                association: $0.readCodedIndex())
        }
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                generation: $0.readConstant(),
                name: $0.readHeapOffset(),
                mvid: $0.readHeapOffset(),
                encId: $0.readHeapOffset(),
                encBaseId: $0.readHeapOffset())
        }
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                flags: $0.readConstant(),
                sequence: $0.readConstant(),
                name: $0.readHeapOffset())
        }
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                flags: $0.readConstant(),
                name: $0.readHeapOffset(),
                type: $0.readHeapOffset())
        }
    }
}

public struct PropertyMap {
    public var parent: Table<TypeDef>.RowIndex?
    public var propertyList: Table<Property>.RowIndex?
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                parent: $0.readTableRowIndex(),
                propertyList: $0.readTableRowIndex())
        }
    }
}

public struct StandAloneSig {
    public var signature: HeapOffset<BlobHeap>
}

extension StandAloneSig: TableRow {
    public static var tableIndex: TableIndex { .standAloneSig }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingHeapOffset(\.signature)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                signature: $0.readHeapOffset())
        }
    }
}

public struct TypeDef {
    public var flags: TypeAttributes
    public var typeName: HeapOffset<StringHeap>
    public var typeNamespace: HeapOffset<StringHeap>
    public var extends: TypeDefOrRef
    public var fieldList: Table<Field>.RowIndex?
    public var methodList: Table<MethodDef>.RowIndex?
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                flags: $0.readConstant(),
                typeName: $0.readHeapOffset(),
                typeNamespace: $0.readHeapOffset(),
                extends: $0.readCodedIndex(),
                fieldList: $0.readTableRowIndex(),
                methodList: $0.readTableRowIndex())
        }
    }
}

public struct TypeRef {
    public var resolutionScope: ResolutionScope
    public var typeName: HeapOffset<StringHeap>
    public var typeNamespace: HeapOffset<StringHeap>
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                resolutionScope: $0.readCodedIndex(),
                typeName: $0.readHeapOffset(),
                typeNamespace: $0.readHeapOffset())
        }
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
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                signature: $0.readHeapOffset())
        }
    }
}
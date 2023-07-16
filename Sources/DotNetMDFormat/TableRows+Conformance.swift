
extension TableRows.Assembly: TableRow {
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

extension TableRows.AssemblyRef: TableRow {
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

extension TableRows.ClassLayout: TableRow {
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

extension TableRows.Constant: KeyedTableRow {
    public var primaryKey: MetadataToken.TableKey { MetadataToken(parent).tableKey }

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

extension TableRows.CustomAttribute: KeyedTableRow {
    public var primaryKey: MetadataToken.TableKey { MetadataToken(parent).tableKey }

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

extension TableRows.DeclSecurity: TableRow {
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

extension TableRows.Event: TableRow {
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

extension TableRows.EventMap: TableRow {
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

extension TableRows.Field: TableRow {
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

extension TableRows.FieldLayout: TableRow {
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

extension TableRows.FieldMarshal: TableRow {
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

extension TableRows.FieldRva: TableRow {
    public static var tableIndex: TableIndex { .fieldRva }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.rva)
            .addingTableRowIndex(\.field)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                rva: $0.readConstant(),
                field: $0.readTableRowIndex())
        }
    }
}

extension TableRows.File: TableRow {
    public static var tableIndex: TableIndex { .file }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.flags)
            .addingHeapOffset(\.name)
            .addingHeapOffset(\.hashValue)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                flags: $0.readConstant(),
                name: $0.readHeapOffset(),
                hashValue: $0.readHeapOffset())
        }
    }
}

extension TableRows.GenericParam: DoublyKeyedTableRow {
    public var primaryKey: MetadataToken.TableKey { MetadataToken(owner).tableKey }
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

extension TableRows.GenericParamConstraint: KeyedTableRow {
    public var primaryKey: MetadataToken.TableKey { MetadataToken(owner).tableKey }

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

extension TableRows.ImplMap: TableRow {
    public static var tableIndex: TableIndex { .implMap }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.mappingFlags)
            .addingCodedIndex(\.memberForwarded)
            .addingHeapOffset(\.importName)
            .addingTableRowIndex(\.importScope)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                mappingFlags: $0.readConstant(),
                memberForwarded: $0.readCodedIndex(),
                importName: $0.readHeapOffset(),
                importScope: $0.readTableRowIndex())
        }
    }
}

extension TableRows.InterfaceImpl: DoublyKeyedTableRow {
    public var primaryKey: MetadataToken.TableKey { MetadataToken(`class`).tableKey }
    public var secondaryKey: MetadataToken.TableKey { MetadataToken(interface).tableKey }

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

extension TableRows.ManifestResource: TableRow {
    public static var tableIndex: TableIndex { .manifestResource }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.offset)
            .addingConstant(\.flags)
            .addingHeapOffset(\.name)
            .addingCodedIndex(\.implementation)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                offset: $0.readConstant(),
                flags: $0.readConstant(),
                name: $0.readHeapOffset(),
                implementation: $0.readCodedIndex())
        }
    }
}

extension TableRows.MemberRef: TableRow {
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

extension TableRows.MethodDef: TableRow {
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

extension TableRows.MethodImpl: KeyedTableRow {
    public var primaryKey: MetadataToken.TableKey { MetadataToken(`class`).tableKey }

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

extension TableRows.MethodSemantics: KeyedTableRow {
    public var primaryKey: MetadataToken.TableKey { MetadataToken(association).tableKey }

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

extension TableRows.MethodSpec: TableRow {
    public static var tableIndex: TableIndex { .methodSpec }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingCodedIndex(\.method)
            .addingHeapOffset(\.instantiation)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                method: $0.readCodedIndex(),
                instantiation: $0.readHeapOffset())
        }
    }
}

extension TableRows.Module: TableRow {
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

extension TableRows.ModuleRef: TableRow {
    public static var tableIndex: TableIndex { .moduleRef }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingHeapOffset(\.name)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                name: $0.readHeapOffset())
        }
    }
}

extension TableRows.NestedClass: KeyedTableRow {
    public var primaryKey: MetadataToken.TableKey { MetadataToken(nestedClass).tableKey }

    public static var tableIndex: TableIndex { .nestedClass }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowIndex(\.nestedClass)
            .addingTableRowIndex(\.enclosingClass)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                nestedClass: $0.readTableRowIndex(),
                enclosingClass: $0.readTableRowIndex())
        }
    }
}

extension TableRows.Param: TableRow {
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

extension TableRows.Property: TableRow {
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

extension TableRows.PropertyMap: TableRow {
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

extension TableRows.StandAloneSig: TableRow {
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

extension TableRows.TypeDef: TableRow {
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

extension TableRows.TypeRef: TableRow {
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

extension TableRows.TypeSpec: TableRow {
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
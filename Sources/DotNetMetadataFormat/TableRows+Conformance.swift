
extension TableRows.Assembly: TableRow {
    public static var tableID: TableID { .assembly }

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
    public static var tableID: TableID { .assemblyRef }

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

extension TableRows.ClassLayout: KeyedTableRow {
    public var primaryKey: TypeDefTable.RowRef { parent }

    public static var tableID: TableID { .classLayout }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.packingSize)
            .addingConstant(\.classSize)
            .addingTableRowRef(\.parent)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                packingSize: $0.readConstant(),
                classSize: $0.readConstant(),
                parent: $0.readTableRowRef())
        }
    }
}

extension TableRows.Constant: KeyedTableRow {
    public var primaryKey: CodedIndices.HasConstant { parent }

    public static var tableID: TableID { .constant }

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
    public var primaryKey: CodedIndices.HasCustomAttribute { parent }

    public static var tableID: TableID { .customAttribute }

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
    public static var tableID: TableID { .declSecurity }

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
    public static var tableID: TableID { .event }

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
    public static var tableID: TableID { .eventMap }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowRef(\.parent)
            .addingTableRowRef(\.eventList)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                parent: $0.readTableRowRef(),
                eventList: $0.readTableRowRef())
        }
    }
}

extension TableRows.ExportedType: TableRow {
    public static var tableID: TableID { .exportedType }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.type)
            .addingConstant(\.typeDefId)
            .addingHeapOffset(\.typeName)
            .addingHeapOffset(\.typeNamespace)
            .addingCodedIndex(\.implementation)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                type: $0.readConstant(),
                typeDefId: $0.readConstant(),
                typeName: $0.readHeapOffset(),
                typeNamespace: $0.readHeapOffset(),
                implementation: $0.readCodedIndex())
        }
    }
}

extension TableRows.Field: TableRow {
    public static var tableID: TableID { .field }

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

extension TableRows.FieldLayout: KeyedTableRow {
    public var primaryKey: FieldTable.RowRef { field }

    public static var tableID: TableID { .fieldLayout }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.offset)
            .addingTableRowRef(\.field)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                offset: $0.readConstant(),
                field: $0.readTableRowRef())
        }
    }
}

extension TableRows.FieldMarshal: TableRow {
    public static var tableID: TableID { .fieldMarshal }

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
    public static var tableID: TableID { .fieldRva }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.rva)
            .addingTableRowRef(\.field)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                rva: $0.readConstant(),
                field: $0.readTableRowRef())
        }
    }
}

extension TableRows.File: TableRow {
    public static var tableID: TableID { .file }

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
    public var primaryKey: CodedIndices.TypeOrMethodDef { owner }
    public var secondaryKey: UInt16 { number }

    public static var tableID: TableID { .genericParam }

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
    public var primaryKey: GenericParamTable.RowRef { owner }

    public static var tableID: TableID { .genericParamConstraint }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowRef(\.owner)
            .addingCodedIndex(\.constraint)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                owner: $0.readTableRowRef(),
                constraint: $0.readCodedIndex())
        }
    }
}

extension TableRows.ImplMap: TableRow {
    public static var tableID: TableID { .implMap }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.mappingFlags)
            .addingCodedIndex(\.memberForwarded)
            .addingHeapOffset(\.importName)
            .addingTableRowRef(\.importScope)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                mappingFlags: $0.readConstant(),
                memberForwarded: $0.readCodedIndex(),
                importName: $0.readHeapOffset(),
                importScope: $0.readTableRowRef())
        }
    }
}

extension TableRows.InterfaceImpl: DoublyKeyedTableRow {
    public var primaryKey: TypeDefTable.RowRef { `class` }
    public var secondaryKey: CodedIndices.TypeDefOrRef { interface }

    public static var tableID: TableID { .interfaceImpl }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowRef(\.`class`)
            .addingCodedIndex(\.interface)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                class: $0.readTableRowRef(),
                interface: $0.readCodedIndex())
        }
    }
}

extension TableRows.ManifestResource: TableRow {
    public static var tableID: TableID { .manifestResource }

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
    public static var tableID: TableID { .memberRef }

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
    public static var tableID: TableID { .methodDef }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.rva)
            .addingConstant(\.implFlags)
            .addingConstant(\.flags)
            .addingHeapOffset(\.name)
            .addingHeapOffset(\.signature)
            .addingTableRowRef(\.paramList)
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
                paramList: $0.readTableRowRef())
        }
    }
}

extension TableRows.MethodImpl: KeyedTableRow {
    public var primaryKey: TypeDefTable.RowRef { `class` }

    public static var tableID: TableID { .methodImpl }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowRef(\.`class`)
            .addingCodedIndex(\.methodBody)
            .addingCodedIndex(\.methodDeclaration)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                class: $0.readTableRowRef(),
                methodBody: $0.readCodedIndex(),
                methodDeclaration: $0.readCodedIndex())
        }
    }
}

extension TableRows.MethodSemantics: KeyedTableRow {
    public var primaryKey: CodedIndices.HasSemantics { association }

    public static var tableID: TableID { .methodSemantics }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.semantics)
            .addingTableRowRef(\.method)
            .addingCodedIndex(\.association)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                semantics: $0.readConstant(),
                method: $0.readTableRowRef(),
                association: $0.readCodedIndex())
        }
    }
}

extension TableRows.MethodSpec: TableRow {
    public static var tableID: TableID { .methodSpec }

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
    public static var tableID: TableID { .module }

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
    public static var tableID: TableID { .moduleRef }

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
    public var primaryKey: TypeDefTable.RowRef { nestedClass }

    public static var tableID: TableID { .nestedClass }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowRef(\.nestedClass)
            .addingTableRowRef(\.enclosingClass)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                nestedClass: $0.readTableRowRef(),
                enclosingClass: $0.readTableRowRef())
        }
    }
}

extension TableRows.Param: TableRow {
    public static var tableID: TableID { .param }

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
    public static var tableID: TableID { .property }

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
    public static var tableID: TableID { .propertyMap }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingTableRowRef(\.parent)
            .addingTableRowRef(\.propertyList)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                parent: $0.readTableRowRef(),
                propertyList: $0.readTableRowRef())
        }
    }
}

extension TableRows.StandAloneSig: TableRow {
    public static var tableID: TableID { .standAloneSig }

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
    public static var tableID: TableID { .typeDef }

    public static func getSize(sizes: TableSizes) -> Int {
        TableRowSizeBuilder<Self>(sizes: sizes)
            .addingConstant(\.flags)
            .addingHeapOffset(\.typeName)
            .addingHeapOffset(\.typeNamespace)
            .addingCodedIndex(\.extends)
            .addingTableRowRef(\.fieldList)
            .addingTableRowRef(\.methodList)
            .size
    }

    public init(reading buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
        self = TableRowReader.read(buffer: buffer, sizes: sizes) {
            Self(
                flags: $0.readConstant(),
                typeName: $0.readHeapOffset(),
                typeNamespace: $0.readHeapOffset(),
                extends: $0.readCodedIndex(),
                fieldList: $0.readTableRowRef(),
                methodList: $0.readTableRowRef())
        }
    }
}

extension TableRows.TypeRef: TableRow {
    public static var tableID: TableID { .typeRef }

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
    public static var tableID: TableID { .typeSpec }

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
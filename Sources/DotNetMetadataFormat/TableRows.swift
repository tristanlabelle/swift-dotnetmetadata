public enum TableRows {
    public struct Assembly {
        public var hashAlgId: AssemblyHashAlgorithm
        public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
        public var flags: AssemblyFlags
        public var publicKey: BlobHeap.Offset
        public var name: StringHeap.Offset
        public var culture: StringHeap.Offset

        public var version: AssemblyVersion {
            .init(
                major: majorVersion,
                minor: minorVersion,
                buildNumber: buildNumber,
                revisionNumber: revisionNumber)
        }
    }

    public struct AssemblyRef {
        public var majorVersion: UInt16, minorVersion: UInt16, buildNumber: UInt16, revisionNumber: UInt16
        public var flags: AssemblyFlags
        public var publicKeyOrToken: BlobHeap.Offset
        public var name: StringHeap.Offset
        public var culture: StringHeap.Offset
        public var hashValue: BlobHeap.Offset
        
        public var version: AssemblyVersion {
            .init(
                major: majorVersion,
                minor: minorVersion,
                buildNumber: buildNumber,
                revisionNumber: revisionNumber)
        }
    }

    public struct ClassLayout {
        public var packingSize: UInt16
        public var classSize: UInt32
        public var parent: TypeDefTable.RowIndex?
    }

    public struct Constant {
        public var type: ConstantType
        public var parent: CodedIndices.HasConstant
        public var value: BlobHeap.Offset
    }

    public struct CustomAttribute {
        public var parent: CodedIndices.HasCustomAttribute
        public var type: CodedIndices.CustomAttributeType
        public var value: BlobHeap.Offset
    }

    public struct DeclSecurity {
        public var action: UInt16
        public var parent: CodedIndices.HasDeclSecurity
        public var permissionSet: BlobHeap.Offset
    }

    public struct Event {
        public var eventFlags: EventAttributes
        public var name: StringHeap.Offset
        public var eventType: CodedIndices.TypeDefOrRef
    }

    public struct EventMap {
        public var parent: TypeDefTable.RowIndex?
        public var eventList: EventTable.RowIndex?
    }

    public struct ExportedType {
        public var type: TypeAttributes
        public var typeDefId: UInt32
        public var typeName: StringHeap.Offset
        public var typeNamespace: StringHeap.Offset
        public var implementation: CodedIndices.Implementation
    }

    public struct Field {
        public var flags: FieldAttributes
        public var name: StringHeap.Offset
        public var signature: BlobHeap.Offset
    }

    public struct FieldLayout {
        public var offset: UInt32
        public var field: FieldTable.RowIndex?
    }

    public struct FieldMarshal {
        public var parent: CodedIndices.HasFieldMarshal
        public var nativeType: BlobHeap.Offset
    }

    public struct FieldRva {
        public var rva: UInt32
        public var field: FieldTable.RowIndex?
    }

    public struct File {
        public var flags: FileAttributes
        public var name: StringHeap.Offset
        public var hashValue: BlobHeap.Offset
    }

    public struct GenericParam {
        public var number: UInt16
        public var flags: GenericParamAttributes
        public var owner: CodedIndices.TypeOrMethodDef
        public var name: StringHeap.Offset
    }

    public struct GenericParamConstraint {
        public var owner: GenericParamTable.RowIndex?
        public var constraint: CodedIndices.TypeDefOrRef
    }

    public struct ImplMap {
        public var mappingFlags: PInvokeAttributes
        public var memberForwarded: CodedIndices.MemberForwarded
        public var importName: StringHeap.Offset
        public var importScope: ModuleRefTable.RowIndex?
    }

    public struct InterfaceImpl {
        public var `class`: TypeDefTable.RowIndex?
        public var interface: CodedIndices.TypeDefOrRef
    }

    public struct ManifestResource {
        public var offset: UInt32
        public var flags: ManifestResourceAttributes
        public var name: StringHeap.Offset
        public var implementation: CodedIndices.Implementation
    }

    public struct MemberRef {
        public var `class`: CodedIndices.MemberRefParent
        public var name: StringHeap.Offset
        public var signature: BlobHeap.Offset
    }

    public struct MethodDef {
        public var rva: UInt32
        public var implFlags: MethodImplAttributes
        public var flags: MethodAttributes
        public var name: StringHeap.Offset
        public var signature: BlobHeap.Offset
        public var paramList: ParamTable.RowIndex?
    }

    public struct MethodImpl {
        public var `class`: TypeDefTable.RowIndex?
        public var methodBody: CodedIndices.MethodDefOrRef
        public var methodDeclaration: CodedIndices.MethodDefOrRef
    }

    public struct MethodSemantics {
        public var semantics: MethodSemanticsAttributes
        public var method: MethodDefTable.RowIndex?
        public var association: CodedIndices.HasSemantics
    }

    public struct MethodSpec {
        public var method: CodedIndices.MethodDefOrRef
        public var instantiation: BlobHeap.Offset
    }

    public struct Module {
        public var generation: UInt16
        public var name: StringHeap.Offset
        public var mvid: GuidHeap.Offset
        public var encId: GuidHeap.Offset
        public var encBaseId: GuidHeap.Offset
    }

    public struct ModuleRef {
        public var name: StringHeap.Offset
    }

    public struct NestedClass {
        public var nestedClass: TypeDefTable.RowIndex?
        public var enclosingClass: TypeDefTable.RowIndex?
    }

    public struct Param {
        public var flags: ParamAttributes
        public var sequence: UInt16
        public var name: StringHeap.Offset
    }

    public struct Property {
        public var flags: PropertyAttributes
        public var name: StringHeap.Offset
        public var type: BlobHeap.Offset
    }

    public struct PropertyMap {
        public var parent: TypeDefTable.RowIndex?
        public var propertyList: PropertyTable.RowIndex?
    }

    public struct StandAloneSig {
        public var signature: BlobHeap.Offset
    }

    public struct TypeDef {
        public var flags: TypeAttributes
        public var typeName: StringHeap.Offset
        public var typeNamespace: StringHeap.Offset
        public var extends: CodedIndices.TypeDefOrRef
        public var fieldList: FieldTable.RowIndex?
        public var methodList: MethodDefTable.RowIndex?
    }

    public struct TypeRef {
        public var resolutionScope: CodedIndices.ResolutionScope
        public var typeName: StringHeap.Offset
        public var typeNamespace: StringHeap.Offset
    }

    public struct TypeSpec {
        public var signature: BlobHeap.Offset
    }
}
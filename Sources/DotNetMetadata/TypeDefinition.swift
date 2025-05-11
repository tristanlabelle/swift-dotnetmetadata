import DotNetMetadataFormat

/// An unbound type definition, which may have generic parameters.
public class TypeDefinition: CustomDebugStringConvertible, Attributable {
    internal typealias Kind = TypeDefinitionKind

    public private(set) weak var assembly: Assembly!
    public let tableRowIndex: TableRowIndex // In TypeDef table

    fileprivate init(assembly: Assembly, tableRowIndex: TableRowIndex) {
        self.assembly = assembly
        self.tableRowIndex = tableRowIndex
    }

    internal static func create(assembly: Assembly, tableRowIndex: TableRowIndex) -> TypeDefinition {
        // Figuring out the kind requires checking the base type,
        // but we must be careful to not look up any other `TypeDefinition`
        // instances since they might not have been created yet.
        // For safety, implement this at the physical layer.
        let tableRow = assembly.moduleFile.typeDefTable[tableRowIndex]
        let kind = (try? assembly.moduleFile.getTypeDefinitionKind(tableRow)) ?? .class

        switch kind {
            case .class: return ClassDefinition(assembly: assembly, tableRowIndex: tableRowIndex)
            case .interface: return InterfaceDefinition(assembly: assembly, tableRowIndex: tableRowIndex)
            case .delegate: return DelegateDefinition(assembly: assembly, tableRowIndex: tableRowIndex)
            case .struct: return StructDefinition(assembly: assembly, tableRowIndex: tableRowIndex)
            case .enum: return EnumDefinition(assembly: assembly, tableRowIndex: tableRowIndex)
        }
    }

    public var context: AssemblyLoadContext { assembly.context }
    internal var moduleFile: ModuleFile { assembly.moduleFile }
    private var tableRow: TypeDefTable.Row { moduleFile.typeDefTable[tableRowIndex] }

    public var kind: TypeDefinitionKind { fatalError() }
    public var isValueType: Bool { kind.isValueType }
    public var isReferenceType: Bool { kind.isReferenceType }

    private var _cachedName: String?
    public var name: String {
        if let name = _cachedName { return name }
        _cachedName = moduleFile.resolve(tableRow.typeName)
        return _cachedName!
    }
    public var nameWithoutGenericArity: String { TypeName.trimGenericArity(name) }

    public var namespace: String? {
        let tableRow = tableRow
        // Normally, no namespace is represented by a zero string heap index
        guard tableRow.typeNamespace.value != 0 else { return nil }
        let value = moduleFile.resolve(tableRow.typeNamespace)
        return value.isEmpty ? nil : value
    }

    private var cachedFullName: String?
    public var fullName: String { get {
        cachedFullName.lazyInit {
            if let enclosingType = try? enclosingType {
                assert(namespace == nil)
                return "\(enclosingType.fullName)\(TypeName.nestedTypeSeparator)\(name)"
            }
            return TypeName.toFullName(namespace: namespace, shortName: name)
        }
    } }

    internal var metadataFlags: DotNetMetadataFormat.TypeAttributes { tableRow.flags }

    public var nameKind: NameKind { metadataFlags.nameKind }
    public var visibility: Visibility { metadataFlags.visibility }
    public var isPublic: Bool { visibility == .public }
    public var isNested: Bool { metadataFlags.isNested }
    public var layoutKind: LayoutKind { metadataFlags.layoutKind }

    public var debugDescription: String { "\(fullName) (\(assembly.name) \(assembly.version))" }

    private var cachedLayout: TypeLayout?
    public var layout: TypeLayout { get {
        cachedLayout.lazyInit {
            switch metadataFlags.layoutKind {
                case .auto: return .auto
                case .sequential:
                    let layout = getClassLayout()
                    return .sequential(pack: layout.pack == 0 ? nil : Int(layout.pack), minSize: Int(layout.size))
                case .explicit:
                    return .explicit(minSize: Int(getClassLayout().size))
            }

            func getClassLayout() -> (pack: UInt16, size: UInt32) {
                if let classLayoutRowIndex = moduleFile.classLayoutTable.findAny(primaryKey: .init(index: tableRowIndex)) {
                    let classLayoutRow = moduleFile.classLayoutTable[classLayoutRowIndex]
                    return (pack: classLayoutRow.packingSize, size: classLayoutRow.classSize)
                }
                else {
                    return (pack: 0, size: 0)
                }
            }
        }
    } }

    private var cachedEnclosingType: TypeDefinition??
    public var enclosingType: TypeDefinition? { get throws {
        try cachedEnclosingType.lazyInit {
            guard let nestedClassRowIndex = moduleFile.nestedClassTable.findAny(primaryKey: .init(index: tableRowIndex)) else { return nil }
            guard let enclosingTypeDefRowIndex = moduleFile.nestedClassTable[nestedClassRowIndex].enclosingClass.index else { return nil }
            return try assembly.resolveTypeDef(rowIndex: enclosingTypeDefRowIndex)
        }
    } }

    private var cachedGenericParams: [GenericTypeParam]?

    /// The list of generic parameters on this type definition.
    /// By CLS rules, generic parameters on the enclosing type should be redeclared
    /// in the nested type, i.e. given "Enclosing<T>.Nested<U>" in C#, the metadata
    /// for "Nested" should have generic parameters T (redeclared) and U.
    public var genericParams: [GenericTypeParam] {
        get {
            cachedGenericParams.lazyInit {
                moduleFile.genericParamTable.findAll(primaryKey: .init(tag: .typeDef, rowIndex: tableRowIndex)).map {
                    GenericTypeParam(definingType: self, tableRowIndex: $0)
                }
            }
        }
    }

    public var genericArity: Int { genericParams.count }

    private var cachedBase: BoundType??
    public var base: BoundType? { get throws {
        try cachedBase.lazyInit {
            try assembly.resolveTypeDefOrRefToBoundType(tableRow.extends)
        }
    } }

    private var cachedBaseInterfaces: [BaseInterface]?
    public var baseInterfaces: [BaseInterface] {
        cachedBaseInterfaces.lazyInit {
            moduleFile.interfaceImplTable.findAll(primaryKey: .init(index: tableRowIndex)).map {
                BaseInterface(inheritingType: self, tableRowIndex: $0)
            }
        }
    }

    private var cachedMethods: [Method]?
    public var methods: [Method] {
        cachedMethods.lazyInit {
            getChildRowRange(parent: moduleFile.typeDefTable,
                parentRowIndex: tableRowIndex,
                childTable: moduleFile.methodDefTable,
                childSelector: { $0.methodList }).map {
                Method.create(definingType: self, tableRowIndex: $0)
            }
        }
    }

    private var cachedFields: [Field]?
    public var fields: [Field] {
        cachedFields.lazyInit {
            getChildRowRange(parent: moduleFile.typeDefTable,
                parentRowIndex: tableRowIndex,
                childTable: moduleFile.fieldTable,
                childSelector: { $0.fieldList }).map {
                Field(definingType: self, tableRowIndex: $0)
            }
        }
    }

    private var cachedProperties: [Property]?
    public var properties: [Property] {
        cachedProperties.lazyInit {
            guard let propertyMapRowIndex = assembly.findPropertyMapForTypeDef(rowIndex: tableRowIndex).index else { return [] }
            return getChildRowRange(parent: moduleFile.propertyMapTable,
                parentRowIndex: propertyMapRowIndex,
                childTable: moduleFile.propertyTable,
                childSelector: { $0.propertyList }).map { Property.create(definingType: self, tableRowIndex: $0) }
        }
    }

    private var cachedEvents: [Event]?
    public var events: [Event] {
        cachedEvents.lazyInit {
            guard let eventMapRowIndex: TableRowIndex = assembly.findEventMapForTypeDef(rowIndex: tableRowIndex).index else { return [] }
            return getChildRowRange(parent: moduleFile.eventMapTable,
                parentRowIndex: eventMapRowIndex,
                childTable: moduleFile.eventTable,
                childSelector: { $0.eventList }).map { Event(definingType: self, tableRowIndex: $0) }
        }
    }

    public var attributeTarget: AttributeTargets { fatalError() }

    private var cachedAttributes: [Attribute]?
    public var attributes: [Attribute] {
        cachedAttributes.lazyInit {
            assembly.getAttributes(owner: .init(tag: .typeDef, rowIndex: tableRowIndex))
        }
    }

    private var cachedNestedTypes: [TypeDefinition]?
    public var nestedTypes: [TypeDefinition] { get throws {
        try cachedNestedTypes.lazyInit {
            try moduleFile.nestedClassTable.findAllNested(enclosing: .init(index: tableRowIndex)).map {
                let nestedTypeRowIndex = moduleFile.nestedClassTable[$0].nestedClass.index!
                return try assembly.resolveTypeDef(rowIndex: nestedTypeRowIndex)
            }
        }
    } }

    internal func getAccessors(owner: CodedIndices.HasSemantics) -> [(method: Method, attributes: MethodSemanticsAttributes)] {
        moduleFile.methodSemanticsTable.findAll(primaryKey: owner).map {
            let row = moduleFile.methodSemanticsTable[$0]
            let method = methods.first { $0.tableRowIndex == row.method.index }!
            return (method, row.semantics)
        }
    }

    internal func breakReferenceCycles() {
        if let genericParams = cachedGenericParams {
            for genericParam in genericParams {
                genericParam.breakReferenceCycles()
            }
        }

        if let baseInterfaces = cachedBaseInterfaces {
            for baseInterface in baseInterfaces {
                baseInterface.breakReferenceCycles()
            }
        }

        if let methods = cachedMethods {
            for method in methods {
                method.breakReferenceCycles()
            }
        }

        if let fields = cachedFields {
            for field in fields {
                field.breakReferenceCycles()
            }
        }

        if let properties = cachedProperties {
            for property in properties {
                property.breakReferenceCycles()
            }
        }

        if let events = cachedEvents {
            for event in events {
                event.breakReferenceCycles()
            }
        }

        if let attributes = cachedAttributes {
            for attribute in attributes {
                attribute.breakReferenceCycles()
            }
        }

        cachedEnclosingType = nil
        cachedBase = nil
        cachedAttributes = nil
        cachedNestedTypes = nil
        // cachedLayout is POD, no need to nil it
    }
}

public final class ClassDefinition: TypeDefinition {
    public override var kind: TypeDefinitionKind { .class }
    public override var attributeTarget: AttributeTargets { .class }

    public var isAbstract: Bool { metadataFlags.contains(TypeAttributes.abstract) }
    public var isSealed: Bool { metadataFlags.contains(TypeAttributes.sealed) }
    public var isStatic: Bool { isAbstract && isSealed }

    public var finalizer: Method? { findMethod(name: "Finalize", static: false, arity: 0) }
}

public final class InterfaceDefinition: TypeDefinition {
    public override var kind: TypeDefinitionKind { .interface }
    public override var attributeTarget: AttributeTargets { .interface }
}

public final class DelegateDefinition: TypeDefinition {
    public override var kind: TypeDefinitionKind { .delegate }
    public override var attributeTarget: AttributeTargets { .delegate }

    public var invokeMethod: Method { findMethod(name: "Invoke", public: true, static: false)! }
    public var arity: Int { get throws { try invokeMethod.arity } }
}

public final class StructDefinition: TypeDefinition {
    public override var kind: TypeDefinitionKind { .struct }
    public override var attributeTarget: AttributeTargets { .struct }
}

public final class EnumDefinition: TypeDefinition {
    public override var kind: TypeDefinitionKind { .enum }
    public override var attributeTarget: AttributeTargets { .enum }

    public var backingField: Field {
        // The backing field may be public but will have specialName and rtSpecialName
        findField(name: "value__", static: false)!
    }

    public var underlyingType: TypeDefinition { get throws { try backingField.type.asDefinition! } }

    private lazy var _isFlags = Result { try hasAttribute(FlagsAttribute.self) }
    public var isFlags: Bool { get throws { try _isFlags.get() } }
}

extension TypeDefinition: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: TypeDefinition, rhs: TypeDefinition) -> Bool { lhs === rhs }
}

import DotNetMetadataFormat

public class Member: Attributable {
    public private(set) weak var definingType: TypeDefinition!

    internal init(definingType: TypeDefinition) {
        self.definingType = definingType
    }

    public var assembly: Assembly { definingType.assembly }
    internal var moduleFile: ModuleFile { definingType.moduleFile }
    public var context: AssemblyLoadContext { assembly.context }

    public var metadataToken: MetadataToken { fatalError() } // abstract

    internal var nameStringHeapOffset: StringHeap.Offset { fatalError() } // abstract
    private var _cachedName: String?
    public var name: String {
        if let name = _cachedName { return name }
        _cachedName = moduleFile.resolve(nameStringHeapOffset)
        return _cachedName!
    }

    public var nameKind: NameKind { fatalError() } // abstract
    public var isStatic: Bool { fatalError() } // abstract
    public var isInstance: Bool { !isStatic }

    public var attributeTarget: AttributeTargets { fatalError() } // abstract
    internal var attributesKeyTag: CodedIndices.HasCustomAttribute.Tag { fatalError() } // abstract

    private var cachedAttributes: [Attribute]?
    public var attributes: [Attribute] {
        cachedAttributes.lazyInit {
            assembly.getAttributes(owner: .init(tag: attributesKeyTag, rowIndex: metadataToken.rowIndex))
        }
    }

    internal func breakReferenceCycles() {
        if let attributes = cachedAttributes {
            for attribute in attributes {
                attribute.breakReferenceCycles()
            }
        }
    }
}

extension Member: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Member, rhs: Member) -> Bool { lhs === rhs }
}

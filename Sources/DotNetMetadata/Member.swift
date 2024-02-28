import DotNetMetadataFormat

public class Member: Attributable {
    public unowned let definingType: TypeDefinition

    internal init(definingType: TypeDefinition) {
        self.definingType = definingType
    }

    public var assembly: Assembly { definingType.assembly }
    internal var moduleFile: ModuleFile { definingType.moduleFile }
    public var context: AssemblyLoadContext { assembly.context }

    public var metadataToken: MetadataToken { fatalError() }
    internal func resolveName() -> String { fatalError() }
    public private(set) lazy var name: String = resolveName()
    public var nameKind: NameKind { fatalError() }
    public var isStatic: Bool { fatalError() }
    public var isInstance: Bool { !isStatic }

    public var attributeTarget: AttributeTargets { fatalError() }
    internal var attributesKeyTag: CodedIndices.HasCustomAttribute.Tag { fatalError() }
    public private(set) lazy var attributes: [Attribute] = {
        assembly.getAttributes(owner: .init(tag: attributesKeyTag, oneBasedRowIndex: metadataToken.oneBasedRowIndex))
    }()
}

extension Member: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Member, rhs: Member) -> Bool { lhs === rhs }
}

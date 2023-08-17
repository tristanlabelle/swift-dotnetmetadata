import DotNetMetadataFormat

public class Member {
    public unowned let definingType: TypeDefinition

    internal init(definingType: TypeDefinition) {
        self.definingType = definingType
    }

    internal var assembly: Assembly { definingType.assembly }
    internal var moduleFile: ModuleFile { definingType.moduleFile }
    internal var context: MetadataContext { assembly.context }

    internal func resolveName() -> String { fatalError() }
    public private(set) lazy var name: String = resolveName()
    public var nameKind: NameKind { fatalError() }
    public var visibility: Visibility { fatalError() }
    public var isStatic: Bool { fatalError() }
}

extension Member: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Member, rhs: Member) -> Bool { lhs === rhs }
}

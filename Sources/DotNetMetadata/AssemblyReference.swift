import DotNetMetadataFormat

public final class AssemblyReference {
    public private(set) weak var owner: Assembly!
    internal let tableRowIndex: TableRowIndex // In AssemblyRef table

    init(owner: Assembly, tableRowIndex: TableRowIndex) {
        self.owner = owner
        self.tableRowIndex = tableRowIndex
    }

    internal var moduleFile: ModuleFile { owner.moduleFile }
    internal var tableRow: AssemblyRefTable.Row { moduleFile.assemblyRefTable[tableRowIndex] }

    public var name: String { moduleFile.resolve(tableRow.name) }
    public var version: AssemblyVersion { tableRow.version }

    public var culture: String? {
        let culture = moduleFile.resolve(tableRow.culture)
        return culture.isEmpty ? nil : culture
    }

    public var publicKey: AssemblyPublicKey? {
        let tableRow = tableRow
        let bytes = Array(moduleFile.resolve(tableRow.publicKeyOrToken))
        return bytes.isEmpty ? nil : .from(bytes: bytes, isToken: tableRow.flags.contains(.publicKey))
    }

    public var identity: AssemblyIdentity {
        AssemblyIdentity(name: name, version: version, culture: culture, publicKey: publicKey)
    }

    public var flags: AssemblyFlags { tableRow.flags }
    public var hashValue: [UInt8] { Array(moduleFile.resolve(tableRow.hashValue)) }

    private var cachedAttributes: [Attribute]?
    public var attributes: [Attribute] {
        cachedAttributes.lazyInit {
            owner.getAttributes(owner: .init(tag: .interfaceImpl, rowIndex: tableRowIndex))
        }
    }

    private var cachedTarget: Assembly? = nil
    public func resolve() throws -> Assembly {
        if let cachedTarget { return cachedTarget }
        let target = try owner.context.load(identity: identity)
        self.cachedTarget = target
        return target
    }

    internal func breakReferenceCycles() {
        cachedAttributes = nil
        cachedTarget = nil
    }
}
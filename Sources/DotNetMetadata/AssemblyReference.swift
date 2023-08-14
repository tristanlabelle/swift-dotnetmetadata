import DotNetMetadataFormat

public final class AssemblyReference {
    public unowned let owner: Assembly
    internal let tableRowIndex: AssemblyRefTable.RowIndex
    private unowned var cachedTarget: Assembly? = nil

    init(owner: Assembly, tableRowIndex: AssemblyRefTable.RowIndex) {
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

    public var attributes: [Attribute] {
        owner.getAttributes(owner: .assemblyRef(tableRowIndex))
    }

    public func resolve() throws -> Assembly {
        if let cachedTarget { return cachedTarget }
        let target = try owner.context.loadAssembly(identity: identity)
        self.cachedTarget = target
        return target
    }
}
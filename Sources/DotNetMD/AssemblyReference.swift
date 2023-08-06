import DotNetMDFormat

public final class AssemblyReference {
    internal unowned let assemblyImpl: Assembly.MetadataImpl
    internal let tableRowIndex: AssemblyRefTable.RowIndex
    private unowned var cachedTarget: Assembly? = nil

    init(assemblyImpl: Assembly.MetadataImpl, tableRowIndex: AssemblyRefTable.RowIndex) {
        self.assemblyImpl = assemblyImpl
        self.tableRowIndex = tableRowIndex
    }

    public var source: Assembly { assemblyImpl.owner }
    internal var moduleFile: ModuleFile { assemblyImpl.moduleFile }
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

    public var flags: AssemblyFlags { tableRow.flags }
    public var hashValue: [UInt8] { Array(moduleFile.resolve(tableRow.hashValue)) }

    public var identity: AssemblyIdentity {
        AssemblyIdentity(name: name, version: version, culture: culture, publicKey: publicKey)
    }

    public var attributes: [Attribute] {
        assemblyImpl.getAttributes(owner: .assemblyRef(tableRowIndex))
    }

    public func resolve() throws -> Assembly {
        if let cachedTarget { return cachedTarget }
        let target = try source.context.loadAssembly(identity: identity)
        self.cachedTarget = target
        return target
    }
}
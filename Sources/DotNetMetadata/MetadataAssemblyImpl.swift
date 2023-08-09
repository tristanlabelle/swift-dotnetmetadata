import DotNetMetadataFormat

/// Assembly implementation for real assemblies based on loaded metadata from a PE file.
final class MetadataAssemblyImpl: Assembly.Impl {
    internal private(set) unowned var owner: Assembly!
    internal let moduleFile: ModuleFile
    private let tableRow: AssemblyTable.Row

    internal init(moduleFile: ModuleFile, tableRow: AssemblyTable.Row) {
        self.moduleFile = moduleFile
        self.tableRow = tableRow
    }

    func initialize(owner: Assembly) {
        self.owner = owner
    }

    internal var context: MetadataContext { owner.context }

    public var name: String { moduleFile.resolve(tableRow.name) }

    public var culture: String? {
        let culture = moduleFile.resolve(tableRow.culture)
        return culture.isEmpty ? nil : culture
    }

    public var version: AssemblyVersion {
        .init(
            major: tableRow.majorVersion,
            minor: tableRow.minorVersion,
            buildNumber: tableRow.buildNumber,
            revisionNumber: tableRow.revisionNumber)
    }

    public var publicKey: AssemblyPublicKey? {
        let tableRow = tableRow
        let bytes = Array(moduleFile.resolve(tableRow.publicKey))
        return bytes.isEmpty ? nil : .from(bytes: bytes, isToken: tableRow.flags.contains(.publicKey))
    }

    public private(set) lazy var moduleName: String = moduleFile.resolve(moduleFile.moduleTable[0].name)

    public private(set) lazy var references: [AssemblyReference] = {
        moduleFile.assemblyRefTable.indices.map { 
            AssemblyReference(assemblyImpl: self, tableRowIndex: $0)
        }
    }()

    public private(set) lazy var definedTypes: [TypeDefinition] = {
        moduleFile.typeDefTable.indices.map { 
            TypeDefinition.create(
                assembly: owner,
                impl: TypeDefinition.MetadataImpl(assemblyImpl: self, tableRowIndex: $0))
        }
    }()

    private lazy var propertyMapByTypeDefRowIndex: [TypeDefTable.RowIndex: PropertyMapTable.RowIndex] = {
        .init(uniqueKeysWithValues: moduleFile.propertyMapTable.indices.map {
            (moduleFile.propertyMapTable[$0].parent!, $0)
        })
    }()

    func findPropertyMap(forTypeDef typeDefRowIndex: TypeDefTable.RowIndex) -> PropertyMapTable.RowIndex? {
        propertyMapByTypeDefRowIndex[typeDefRowIndex]
    }

    private lazy var eventMapByTypeDefRowIndex: [TypeDefTable.RowIndex: EventMapTable.RowIndex] = {
        .init(uniqueKeysWithValues: moduleFile.eventMapTable.indices.map {
            (moduleFile.eventMapTable[$0].parent!, $0)
        })
    }()

    func findEventMap(forTypeDef typeDefRowIndex: TypeDefTable.RowIndex) -> EventMapTable.RowIndex? {
        eventMapByTypeDefRowIndex[typeDefRowIndex]
    }

    internal lazy var mscorlib: Mscorlib = {
        if let mscorlib = owner as? Mscorlib {
            return mscorlib
        }

        for assemblyRef in moduleFile.assemblyRefTable {
            let identity = AssemblyIdentity(fromRow: assemblyRef, in: moduleFile)
            if identity.name == Mscorlib.name {
                return try! context.loadAssembly(identity: identity) as! Mscorlib
            }
        }

        fatalError("Can't load mscorlib")
    }()

    internal func getAttributes(owner: HasCustomAttribute) -> [Attribute] {
        moduleFile.customAttributeTable.findAll(primaryKey: owner.metadataToken.tableKey).map {
            Attribute(tableRowIndex: $0, assemblyImpl: self)
        }
    }
}
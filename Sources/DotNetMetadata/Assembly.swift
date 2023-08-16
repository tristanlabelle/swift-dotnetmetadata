import DotNetMetadataFormat

public class Assembly: CustomDebugStringConvertible {
    public let context: MetadataContext
    public let moduleFile: ModuleFile
    private let tableRow: AssemblyTable.Row

    internal init(context: MetadataContext, moduleFile: ModuleFile, tableRow: AssemblyTable.Row) throws {
        self.context = context
        self.moduleFile = moduleFile
        self.tableRow = tableRow
    }

    public var name: String { moduleFile.resolve(tableRow.name) }

    public var version: AssemblyVersion {
        .init(
            major: tableRow.majorVersion,
            minor: tableRow.minorVersion,
            buildNumber: tableRow.buildNumber,
            revisionNumber: tableRow.revisionNumber)
    }

    public var culture: String? {
        let culture = moduleFile.resolve(tableRow.culture)
        return culture.isEmpty ? nil : culture
    }

    public var publicKey: AssemblyPublicKey? {
        let tableRow = tableRow
        let bytes = Array(moduleFile.resolve(tableRow.publicKey))
        return bytes.isEmpty ? nil : .from(bytes: bytes, isToken: tableRow.flags.contains(.publicKey))
    }

    public var identity: AssemblyIdentity {
        AssemblyIdentity(name: name, version: version, culture: culture, publicKey: publicKey)
    }

    public var debugDescription: String { identity.description}

    public private(set) lazy var moduleName: String = moduleFile.resolve(moduleFile.moduleTable[0].name)

    public private(set) lazy var references: [AssemblyReference] = {
        moduleFile.assemblyRefTable.indices.map { 
            AssemblyReference(owner: self, tableRowIndex: $0)
        }
    }()

    public private(set) lazy var definedTypes: [TypeDefinition] = {
        moduleFile.typeDefTable.indices.map { TypeDefinition.create(assembly: self, tableRowIndex: $0) }
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

    public private(set) lazy var typesByFullName: [String: TypeDefinition] = {
        let definedTypes = definedTypes
        var dict = [String: TypeDefinition](minimumCapacity: definedTypes.count)
        for definedType in definedTypes {
            dict[definedType.fullName] = definedType
        }
        return dict
    }()

    public func findDefinedType(fullName: String) -> TypeDefinition? {
        typesByFullName[fullName]
    }

    public func findDefinedType(namespace: String?, name: String) -> TypeDefinition? {
        findDefinedType(fullName: makeFullTypeName(namespace: namespace, name: name))
    }

    public func findDefinedType(namespace: String?, enclosingName: String, nestedNames: [String]) -> TypeDefinition? {
        findDefinedType(fullName: makeFullTypeName(namespace: namespace, enclosingName: enclosingName, nestedNames: nestedNames))
    }
    
    internal lazy var mscorlib: Mscorlib = {
        if let mscorlib = self as? Mscorlib {
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
            Attribute(tableRowIndex: $0, assembly: self)
        }
    }
}

extension Assembly: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Assembly, rhs: Assembly) -> Bool { lhs === rhs }
}
import DotNetMetadataFormat

public class Assembly: CustomDebugStringConvertible {
    public private(set) weak var context: AssemblyLoadContext!
    public let moduleFile: ModuleFile
    private let tableRow: AssemblyTable.Row

    internal init(context: AssemblyLoadContext, moduleFile: ModuleFile, tableRow: AssemblyTable.Row) throws {
        self.context = context
        self.moduleFile = moduleFile
        self.tableRow = tableRow
    }

    public var name: String { moduleFile.resolve(tableRow.name) }

    public var version: FourPartVersion {
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

    public var flags: AssemblyFlags { tableRow.flags }

    public var debugDescription: String { identity.description}

    private var cachedModuleName: String?
    public var moduleName: String {
        cachedModuleName.lazyInit { moduleFile.resolve(moduleFile.moduleTable.first!.name) }
    }

    private var cachedAttributes: [Attribute]?
    public var attributes: [Attribute] {
        cachedAttributes.lazyInit { getAttributes(owner: .init(tag: .assembly, rowIndex: .first)) }
    }

    private var cachedReferences: [AssemblyReference]?
    public var references: [AssemblyReference] {
        cachedReferences.lazyInit {
            moduleFile.assemblyRefTable.indices.map { 
                AssemblyReference(owner: self, tableRowIndex: $0)
            }
        }
    }

    private var cachedTypeDefinitions: [TypeDefinition]?
    public var typeDefinitions: [TypeDefinition] {
        cachedTypeDefinitions.lazyInit {
            moduleFile.typeDefTable.indices.map { TypeDefinition.create(assembly: self, tableRowIndex: $0) }
        }
    }

    private var cachedExportedTypes: [ExportedType]?
    public var exportedTypes: [ExportedType] {
        cachedExportedTypes.lazyInit {
            moduleFile.exportedTypeTable.indices.map { ExportedType(assembly: self, tableRowIndex: $0) }
        }
    }

    private lazy var propertyMapByTypeDefRowIndex: [TypeDefTable.RowRef: TableRowIndex] = {
        .init(uniqueKeysWithValues: moduleFile.propertyMapTable.indices.map {
            (moduleFile.propertyMapTable[$0].parent, $0)
        })
    }()

    func findPropertyMapForTypeDef(rowIndex: TableRowIndex) -> PropertyMapTable.RowRef {
        .init(index: propertyMapByTypeDefRowIndex[.init(index: rowIndex)])
    }

    private lazy var eventMapByTypeDefRowIndex: [TypeDefTable.RowRef: TableRowIndex] = {
        .init(uniqueKeysWithValues: moduleFile.eventMapTable.indices.map {
            (moduleFile.eventMapTable[$0].parent, $0)
        })
    }()

    func findEventMapForTypeDef(rowIndex: TableRowIndex) -> EventMapTable.RowRef {
        .init(index: eventMapByTypeDefRowIndex[.init(index: rowIndex)])
    }

    private var cachedTypeDefinitionsByFullName: [String: TypeDefinition]?
    public var typeDefinitionsByFullName: [String: TypeDefinition] {
        cachedTypeDefinitionsByFullName.lazyInit {
            let typeDefinitions = typeDefinitions
            var dict = [String: TypeDefinition](minimumCapacity: typeDefinitions.count)
            for typeDefinition in typeDefinitions {
                dict[typeDefinition.fullName] = typeDefinition
            }
            return dict
        }
    }

    private var cachedExportedTypesByFullName: [String: ExportedType]?
    public var exportedTypesByFullName: [String: ExportedType] {
        cachedExportedTypesByFullName.lazyInit {
            let exportedTypes = exportedTypes
            var dict = [String: ExportedType](minimumCapacity: exportedTypes.count)
            for exportedType in exportedTypes {
                dict[exportedType.fullName] = exportedType
            }
            return dict
        }
    }

    public func resolveTypeDefinition(fullName: String, allowForwarding: Bool = true) throws -> TypeDefinition? {
        if let typeDefinition = typeDefinitionsByFullName[fullName] { return typeDefinition }
        if let exportedType = exportedTypesByFullName[fullName] { return try exportedType.definition }
        return nil
    }

    public func resolveTypeDefinition(name: TypeName, allowForwarding: Bool = true) throws -> TypeDefinition? {
        try resolveTypeDefinition(fullName: name.fullName, allowForwarding: allowForwarding)
    }

    public func resolveTypeDefinition(namespace: String, name: String, allowForwarding: Bool = true) throws -> TypeDefinition? {
        try resolveTypeDefinition(name: TypeName(namespace: namespace, shortName: name), allowForwarding: allowForwarding)
    }

    internal func getAttributes(owner: CodedIndices.HasCustomAttribute) -> [Attribute] {
        moduleFile.customAttributeTable.findAll(primaryKey: owner).map {
            Attribute(tableRowIndex: $0, assembly: self)
        }
    }

    internal func breakReferenceCycles() {
        if let attributes = cachedAttributes {
            for attribute in attributes {
                attribute.breakReferenceCycles()
            }
        }

        if let references = cachedReferences {
            for reference in references {
                reference.breakReferenceCycles()
            }
        }

        if let typeDefinitions = cachedTypeDefinitions {
            for typeDefinition in typeDefinitions {
                typeDefinition.breakReferenceCycles()
            }
        }

        if let exportedTypes = cachedExportedTypes {
            for exportedType in exportedTypes {
                exportedType.breakReferenceCycles()
            }
        }
    }
}

extension Assembly: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Assembly, rhs: Assembly) -> Bool { lhs === rhs }
}
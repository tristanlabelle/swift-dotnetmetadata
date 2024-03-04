import DotNetMetadataFormat

public class Assembly: CustomDebugStringConvertible {
    public let context: AssemblyLoadContext
    public let moduleFile: ModuleFile
    private let tableRow: AssemblyTable.Row

    internal init(context: AssemblyLoadContext, moduleFile: ModuleFile, tableRow: AssemblyTable.Row) throws {
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

    private var _moduleName: String?
    public var moduleName: String { _moduleName.lazyInit { moduleFile.resolve(moduleFile.moduleTable.first!.name) } }

    private var _attributes: [Attribute]?
    public var attributes: [Attribute] { _attributes.lazyInit { getAttributes(owner: .init(tag: .assembly, rowIndex: .first)) } }

    private var _references: [AssemblyReference]?
    public var references: [AssemblyReference] {
        _references.lazyInit {
            moduleFile.assemblyRefTable.indices.map { 
                AssemblyReference(owner: self, tableRowIndex: $0)
            }
        }
    }

    private var _typeDefinitions: [TypeDefinition]?
    public var typeDefinitions: [TypeDefinition] {
        _typeDefinitions.lazyInit {
            moduleFile.typeDefTable.indices.map { TypeDefinition.create(assembly: self, tableRowIndex: $0) }
        }
    }

    private var _exportedTypes: [ExportedType]?
    public var exportedTypes: [ExportedType] {
        _exportedTypes.lazyInit {
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

    private var _typeDefinitionsByFullName: [String: TypeDefinition]?
    public var typeDefinitionsByFullName: [String: TypeDefinition] {
        _typeDefinitionsByFullName.lazyInit {
            let typeDefinitions = typeDefinitions
            var dict = [String: TypeDefinition](minimumCapacity: typeDefinitions.count)
            for typeDefinition in typeDefinitions {
                dict[typeDefinition.fullName] = typeDefinition
            }
            return dict
        }
    }

    private var _exportedTypesByFullName: [String: ExportedType]?
    public var exportedTypesByFullName: [String: ExportedType] {
        _exportedTypesByFullName.lazyInit {
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

    public func resolveTypeDefinition(namespace: String?, name: String, allowForwarding: Bool = true) throws -> TypeDefinition? {
        let fullName = makeFullTypeName(namespace: namespace, name: name)
        return try resolveTypeDefinition(fullName: fullName, allowForwarding: allowForwarding)
    }

    public func resolveTypeDefinition(namespace: String?, enclosingName: String, nestedNames: [String], allowForwarding: Bool = true) throws -> TypeDefinition? {
        let fullName = makeFullTypeName(namespace: namespace, enclosingName: enclosingName, nestedNames: nestedNames)
        return try resolveTypeDefinition(fullName: fullName, allowForwarding: allowForwarding)
    }

    internal func getAttributes(owner: CodedIndices.HasCustomAttribute) -> [Attribute] {
        moduleFile.customAttributeTable.findAll(primaryKey: owner).map {
            Attribute(tableRowIndex: $0, assembly: self)
        }
    }
}

extension Assembly: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Assembly, rhs: Assembly) -> Bool { lhs === rhs }
}
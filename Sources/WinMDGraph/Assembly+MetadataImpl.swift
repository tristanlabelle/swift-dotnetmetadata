import WinMD

/// Implementation for real assemblies based on loaded metadata from a PE file.
extension Assembly {
    final class MetadataImpl: Impl {
        private var assembly: Assembly!
        internal let database: Database
        private let tableRow: WinMD.Assembly

        internal init(database: Database, tableRow: WinMD.Assembly) {
            self.database = database
            self.tableRow = tableRow
        }

        func initialize(owner: Assembly) {
            self.assembly = owner
        }

        private var context: MetadataContext { assembly.context }

        public var name: String { database.heaps.resolve(tableRow.name) }
        public var culture: String { database.heaps.resolve(tableRow.culture) }

        public var version: AssemblyVersion {
            .init(
                major: tableRow.majorVersion,
                minor: tableRow.minorVersion,
                buildNumber: tableRow.buildNumber,
                revisionNumber: tableRow.revisionNumber)
        }

        public private(set) lazy var types: [TypeDefinition] = {
            database.tables.typeDef.indices.map { 
                TypeDefinition(
                    assembly: assembly,
                    impl: TypeDefinition.MetadataImpl(assemblyImpl: self, tableRowIndex: $0))
            }
        }()

        private lazy var propertyMapByTypeDefRowIndex: [Table<TypeDef>.RowIndex: Table<PropertyMap>.RowIndex] = {
            .init(uniqueKeysWithValues: database.tables.propertyMap.indices.map {
                (database.tables.propertyMap[$0].parent!, $0)
            })
        }()

        func findPropertyMap(forTypeDef typeDefRowIndex: Table<TypeDef>.RowIndex) -> Table<PropertyMap>.RowIndex? {
            propertyMapByTypeDefRowIndex[typeDefRowIndex]
        }

        private lazy var eventMapByTypeDefRowIndex: [Table<TypeDef>.RowIndex: Table<EventMap>.RowIndex] = {
            .init(uniqueKeysWithValues: database.tables.eventMap.indices.map {
                (database.tables.eventMap[$0].parent!, $0)
            })
        }()

        func findEventMap(forTypeDef typeDefRowIndex: Table<TypeDef>.RowIndex) -> Table<EventMap>.RowIndex? {
            eventMapByTypeDefRowIndex[typeDefRowIndex]
        }

        private lazy var mscorlib: Mscorlib = {
            if let mscorlib = assembly as? Mscorlib {
                return mscorlib
            }

            for assemblyRef in database.tables.assemblyRef {
                let name = database.heaps.resolve(assemblyRef.name)
                let culture = database.heaps.resolve(assemblyRef.culture)
                if name == Mscorlib.name {
                    return try! context.loadAssembly(name: name, version: assemblyRef.version, culture: culture) as! Mscorlib
                }
            }

            fatalError("Can't load mscorlib")
        }()

        internal func resolveType(_ metadataToken: MetadataToken) -> Type? {
            guard !metadataToken.isNull else { return nil }
            switch metadataToken.tableIndex {
                case .typeDef:
                    return .simple(resolve(Table<TypeDef>.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1)))
                case .typeRef:
                    return .simple(resolve(Table<TypeRef>.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1)))
                default:
                    fatalError("Not implemented: \(metadataToken)")
            }
        }

        internal func resolve(_ codedIndex: TypeDefOrRef) -> TypeDefinition? {
            switch codedIndex {
                case let .typeDef(index):
                    return index == nil ? nil : resolve(index!)
                case let .typeRef(index):
                    return index == nil ? nil : resolve(index!)
                default: fatalError()
            }
        }

        internal func resolve(_ index: Table<TypeDef>.RowIndex) -> TypeDefinition {
            types[Int(index.zeroBased)]
        }

        internal func resolve(_ index: Table<TypeRef>.RowIndex) -> TypeDefinition {
            let row = database.tables.typeRef[index]
            let name = database.heaps.resolve(row.typeName)
            let namespace = database.heaps.resolve(row.typeNamespace)
            switch row.resolutionScope {
                case let .assemblyRef(index):
                    guard let index = index else { break }
                    return resolve(index).findTypeDefinition(namespace: namespace, name: name)!
                default:
                    fatalError("Not implemented: resolution scope \(row.resolutionScope)")
            }
            fatalError("Not implemented: null resolution scope")
        }

        internal func resolve(_ index: Table<AssemblyRef>.RowIndex) -> Assembly {
            let row = database.tables.assemblyRef[index]
            let name = database.heaps.resolve(row.name)
            let culture = database.heaps.resolve(row.culture)
            let version = AssemblyVersion(
                major: row.majorVersion,
                minor: row.minorVersion,
                buildNumber: row.buildNumber,
                revisionNumber: row.revisionNumber)
            return try! context.loadAssembly(name: name, version: version, culture: culture)
        }

        internal func resolve(_ typeSig: TypeSig) -> Type {
            switch typeSig {
                case .void: return .simple(mscorlib.specialTypes.void)
                case .boolean: return .simple(mscorlib.specialTypes.boolean)
                case .char: return .simple(mscorlib.specialTypes.char)
                case let .integer(size, signed): fatalError("Not implemented: resolve integer \(size) \(signed)")
                case let .real(double): return .simple(double ? mscorlib.specialTypes.double : mscorlib.specialTypes.single)
                case .string: return .simple(mscorlib.specialTypes.string)
                case .object: return .simple(mscorlib.specialTypes.object)
                case let .valueType(metadataToken): return resolveType(metadataToken)!
                case let .`class`(metadataToken): return resolveType(metadataToken)!
                default: fatalError("Not implemented: resolve \(typeSig)")
            }
        }
    }
}
import DotNetMDFormat

/// Implementation for real assemblies based on loaded metadata from a PE file.
extension Assembly {
    final class MetadataImpl: Impl {
        internal private(set) unowned var owner: Assembly!
        internal let database: Database
        private let tableRow: AssemblyTable.Row

        internal init(database: Database, tableRow: AssemblyTable.Row) {
            self.database = database
            self.tableRow = tableRow
        }

        func initialize(owner: Assembly) {
            self.owner = owner
        }

        private var context: MetadataContext { owner.context }

        public var name: String { database.heaps.resolve(tableRow.name) }
        public var culture: String { database.heaps.resolve(tableRow.culture) }

        public var version: AssemblyVersion {
            .init(
                major: tableRow.majorVersion,
                minor: tableRow.minorVersion,
                buildNumber: tableRow.buildNumber,
                revisionNumber: tableRow.revisionNumber)
        }

        public private(set) lazy var moduleName: String = database.heaps.resolve(database.tables.module[0].name)

        public private(set) lazy var definedTypes: [TypeDefinition] = {
            database.tables.typeDef.indices.map { 
                TypeDefinition.create(
                    assembly: owner,
                    impl: TypeDefinition.MetadataImpl(assemblyImpl: self, tableRowIndex: $0))
            }
        }()

        private lazy var propertyMapByTypeDefRowIndex: [TypeDefTable.RowIndex: PropertyMapTable.RowIndex] = {
            .init(uniqueKeysWithValues: database.tables.propertyMap.indices.map {
                (database.tables.propertyMap[$0].parent!, $0)
            })
        }()

        func findPropertyMap(forTypeDef typeDefRowIndex: TypeDefTable.RowIndex) -> PropertyMapTable.RowIndex? {
            propertyMapByTypeDefRowIndex[typeDefRowIndex]
        }

        private lazy var eventMapByTypeDefRowIndex: [TypeDefTable.RowIndex: EventMapTable.RowIndex] = {
            .init(uniqueKeysWithValues: database.tables.eventMap.indices.map {
                (database.tables.eventMap[$0].parent!, $0)
            })
        }()

        func findEventMap(forTypeDef typeDefRowIndex: TypeDefTable.RowIndex) -> EventMapTable.RowIndex? {
            eventMapByTypeDefRowIndex[typeDefRowIndex]
        }

        private lazy var mscorlib: Mscorlib = {
            if let mscorlib = owner as? Mscorlib {
                return mscorlib
            }

            for assemblyRef in database.tables.assemblyRef {
                let identity = AssemblyIdentity(fromRow: assemblyRef, in: database)
                if identity.name == Mscorlib.name {
                    return try! context.loadAssembly(identity: identity) as! Mscorlib
                }
            }

            fatalError("Can't load mscorlib")
        }()

        internal func getCustomAttributes(owner: HasCustomAttribute) -> [CustomAttribute] {
            database.tables.customAttribute.findAll(primaryKey: owner.metadataToken.tableKey) {
                rowIndex, _ in CustomAttribute(tableRowIndex: rowIndex, assemblyImpl: self)
            }
        }

        internal func resolveType(_ metadataToken: MetadataToken) -> BoundType? {
            guard !metadataToken.isNull else { return nil }
            switch metadataToken.tableID {
                case .typeDef:
                    return resolve(TypeDefTable.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1)).bindNonGeneric()
                case .typeRef:
                    return resolve(TypeRefTable.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1)).bindNonGeneric()
                case .typeSpec:
                    return resolve(TypeSpecTable.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1))
                default:
                    fatalError("Not implemented: \(metadataToken)")
            }
        }

        internal func resolve(_ codedIndex: TypeDefOrRef, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) -> BoundType? {
            switch codedIndex {
                case let .typeDef(index):
                    guard let index = index else { return nil }
                    return resolve(index).bindNonGeneric()
                case let .typeRef(index):
                    guard let index = index else { return nil }
                    return resolve(index).bindNonGeneric()
                case let .typeSpec(index):
                    guard let index = index else { return nil }
                    return resolve(index, typeContext: typeContext, methodContext: methodContext)
            }
        }

        internal func resolve(_ index: TypeDefTable.RowIndex) -> TypeDefinition {
            definedTypes[Int(index.zeroBased)]
        }

        internal func resolve(_ index: TypeRefTable.RowIndex) -> TypeDefinition {
            let row = database.tables.typeRef[index]
            let name = database.heaps.resolve(row.typeName)
            let namespace = database.heaps.resolve(row.typeNamespace)
            switch row.resolutionScope {
                case let .module(index):
                    // Assume single-module assembly
                    guard index?.zeroBased == 0 else { break }
                    return owner.findDefinedType(namespace: namespace, name: name)!
                case let .assemblyRef(index):
                    guard let index = index else { break }
                    return resolve(index).findDefinedType(namespace: namespace, name: name)!
                default:
                    fatalError("Not implemented: resolution scope \(row.resolutionScope)")
            }
            fatalError("Not implemented: null resolution scope")
        }

        internal func resolve(_ index: TypeSpecTable.RowIndex, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) -> BoundType {
            let typeSpecRow = database.tables.typeSpec[index]
            let signatureBlob = database.heaps.resolve(typeSpecRow.signature)
            let typeSig = try! TypeSig(blob: signatureBlob)
            return resolve(typeSig, typeContext: typeContext, methodContext: methodContext)
        }

        internal func resolve(_ index: AssemblyRefTable.RowIndex) -> Assembly {
            let row = database.tables.assemblyRef[index]
            let identity = AssemblyIdentity(fromRow: row, in: database)
            return try! context.loadAssembly(identity: identity)
        }

        internal func resolve(_ typeSig: TypeSig, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) -> BoundType {
            switch typeSig {
                case .void: return mscorlib.specialTypes.void.bindNonGeneric()
                case .boolean: return mscorlib.specialTypes.boolean.bindNonGeneric()
                case .char: return mscorlib.specialTypes.char.bindNonGeneric()

                case let .integer(size, signed):
                    return mscorlib.specialTypes.getInteger(size, signed: signed).bindNonGeneric()

                case let .real(double):
                    return (double ? mscorlib.specialTypes.double : mscorlib.specialTypes.single).bindNonGeneric()

                case .string: return mscorlib.specialTypes.string.bindNonGeneric()
                case .object: return mscorlib.specialTypes.object.bindNonGeneric()

                case let .defOrRef(index, _, genericArgs):
                    if genericArgs.count > 0 {
                        let genericArgs = genericArgs.map { resolve($0, typeContext: typeContext, methodContext: methodContext) }
                        switch index {
                            case let .typeDef(index): return resolve(index!).bind(genericArgs: genericArgs)
                            case let .typeRef(index): return resolve(index!).bind(genericArgs: genericArgs)
                            default: fatalError("Not implemented: unexpected generic type reference")
                        }
                    }
                    else {
                        return resolve(index)!
                    }

                case let .szarray(_, element):
                    return .array(element: resolve(element, typeContext: typeContext, methodContext: methodContext))

                case let .genericArg(index, method):
                    if method {
                        guard methodContext != nil else { fatalError("Missing a method context for resolving a generic parameter reference") }
                        fatalError("Not implemented: resolve generic method arg")
                    }
                    else {
                        guard let typeContext else { fatalError("Missing a type context for resolving a generic parameter reference") }
                        return .genericArg(param: typeContext.genericParams[Int(index)])
                    }

                default: fatalError("Not implemented: resolve \(typeSig)")
            }
        }

        internal func resolveMethod(_ codedIndex: MemberRefParent, name: String) throws -> Method? {
            switch codedIndex {
                case let .typeDef(index):
                    guard let index = index else { return nil }
                    return resolve(index).findSingleMethod(name: name)
                case let .typeRef(index):
                    guard let index = index else { return nil }
                    return resolve(index).findSingleMethod(name: name)
                default:
                    fatalError("Not implemented: Resolving \(codedIndex)")
            }
        }

        internal func resolve(_ index: MethodDefTable.RowIndex) -> Method {
            // Requires lookup from MethodDef to Type
            fatalError("Not implemented: resolve(MethodDefTable.RowIndex)")
        }

        internal func resolveMethod(_ index: MemberRefTable.RowIndex) throws -> Method? {
            let row = database.tables.memberRef[index]
            let name = database.heaps.resolve(row.name)
            return try resolveMethod(row.class, name: name)
        }

        internal func resolve(_ codedIndex: CustomAttributeType) throws -> Method? {
            switch codedIndex {
                case .methodDef(let index):
                    guard let index = index else { return nil }
                    return resolve(index)
                case .memberRef(let index):
                    guard let index = index else { return nil }
                    return try resolveMethod(index)
            }
        }
    }
}
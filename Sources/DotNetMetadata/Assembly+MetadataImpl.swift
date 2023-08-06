import DotNetMetadataFormat

/// Implementation for real assemblies based on loaded metadata from a PE file.
extension Assembly {
    final class MetadataImpl: Impl {
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

        private var context: MetadataContext { owner.context }

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

        private lazy var mscorlib: Mscorlib = {
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

        internal func resolveType(_ metadataToken: MetadataToken, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) -> TypeNode? {
            guard !metadataToken.isNull else { return nil }
            switch metadataToken.tableID {
                case .typeDef:
                    return resolve(TypeDefTable.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1)).bindNode()
                case .typeRef:
                    return resolve(TypeRefTable.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1)).bindNode()
                case .typeSpec:
                    return resolve(TypeSpecTable.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1), typeContext: typeContext, methodContext: methodContext)
                default:
                    fatalError("Not implemented: \(metadataToken)")
            }
        }

        internal func resolve(_ codedIndex: TypeDefOrRef, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) -> TypeNode? {
            switch codedIndex {
                case let .typeDef(index):
                    guard let index = index else { return nil }
                    return resolve(index).bindNode()
                case let .typeRef(index):
                    guard let index = index else { return nil }
                    return resolve(index).bindNode()
                case let .typeSpec(index):
                    guard let index = index else { return nil }
                    return resolve(index, typeContext: typeContext, methodContext: methodContext)
            }
        }

        internal func resolveOptionalBoundType(_ codedIndex: TypeDefOrRef, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) -> BoundType? {
            guard let typeNode = resolve(codedIndex, typeContext: typeContext, methodContext: methodContext) else { return nil }
            switch typeNode {
                case .bound(let bound): return bound
                default: fatalError("Expected a bound type definition")
            }
        }

        internal func resolve(_ index: TypeDefTable.RowIndex) -> TypeDefinition {
            definedTypes[Int(index.zeroBased)]
        }

        internal func resolve(_ index: TypeRefTable.RowIndex) -> TypeDefinition {
            let row = moduleFile.typeRefTable[index]
            let name = moduleFile.resolve(row.typeName)
            let namespace = moduleFile.resolve(row.typeNamespace)
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

        internal func resolve(_ index: TypeSpecTable.RowIndex, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) -> TypeNode {
            let typeSpecRow = moduleFile.typeSpecTable[index]
            let signatureBlob = moduleFile.resolve(typeSpecRow.signature)
            let typeSig = try! TypeSig(blob: signatureBlob)
            return resolve(typeSig, typeContext: typeContext, methodContext: methodContext)
        }

        internal func resolve(_ index: AssemblyRefTable.RowIndex) -> Assembly {
            let row = moduleFile.assemblyRefTable[index]
            let identity = AssemblyIdentity(fromRow: row, in: moduleFile)
            return try! context.loadAssembly(identity: identity)
        }

        internal func resolve(_ typeSig: TypeSig, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) -> TypeNode {
            switch typeSig {
                case .void: return mscorlib.specialTypes.void.bindNode()
                case .boolean: return mscorlib.specialTypes.boolean.bindNode()
                case .char: return mscorlib.specialTypes.char.bindNode()

                case let .integer(size, signed):
                    return mscorlib.specialTypes.getInteger(size, signed: signed).bindNode()

                case let .real(double):
                    return (double ? mscorlib.specialTypes.double : mscorlib.specialTypes.single).bindNode()

                case .string: return mscorlib.specialTypes.string.bindNode()
                case .object: return mscorlib.specialTypes.object.bindNode()

                case let .defOrRef(index, _, genericArgs):
                    if genericArgs.count > 0 {
                        let genericArgs = genericArgs.map { resolve($0, typeContext: typeContext, methodContext: methodContext) }
                        switch index {
                            case let .typeDef(index): return resolve(index!).bind(fullGenericArgs: genericArgs).asNode
                            case let .typeRef(index): return resolve(index!).bind(fullGenericArgs: genericArgs).asNode
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

        internal func resolve(_ methodDefRowIndex: MethodDefTable.RowIndex) -> Method {
            guard let typeDefRowIndex = moduleFile.typeDefTable.findMethodOwner(methodDefRowIndex) else {
                fatalError("No owner found for method \(methodDefRowIndex)")
            }

            let methodIndex = methodDefRowIndex.zeroBased - moduleFile.typeDefTable[typeDefRowIndex].methodList!.zeroBased
            return resolve(typeDefRowIndex).methods[Int(methodIndex)]
        }

        internal func resolveMethod(_ index: MemberRefTable.RowIndex) throws -> Method? {
            let row = moduleFile.memberRefTable[index]
            let name = moduleFile.resolve(row.name)
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
import DotNetMetadataFormat

extension Assembly {
    internal func resolveType(_ metadataToken: MetadataToken, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) throws -> TypeNode? {
        guard !metadataToken.isNull else { return nil }
        switch metadataToken.tableID {
            case .typeDef:
                return try resolve(TypeDefTable.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1)).bindNode()
            case .typeRef:
                return try resolve(TypeRefTable.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1)).bindNode()
            case .typeSpec:
                return try resolve(TypeSpecTable.RowIndex(zeroBased: metadataToken.oneBasedRowIndex - 1), typeContext: typeContext, methodContext: methodContext)
            default:
                fatalError("Not implemented: \(metadataToken)")
        }
    }

    internal func resolve(_ codedIndex: TypeDefOrRef, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) throws -> TypeNode? {
        switch codedIndex {
            case let .typeDef(index):
                guard let index = index else { return nil }
                return try resolve(index).bindNode()
            case let .typeRef(index):
                guard let index = index else { return nil }
                return try resolve(index).bindNode()
            case let .typeSpec(index):
                guard let index = index else { return nil }
                return try resolve(index, typeContext: typeContext, methodContext: methodContext)
        }
    }

    internal func resolveOptionalBoundType(_ codedIndex: TypeDefOrRef, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) throws -> BoundType? {
        guard let typeNode = try resolve(codedIndex, typeContext: typeContext, methodContext: methodContext) else { return nil }
        switch typeNode {
            case .bound(let bound): return bound
            default: fatalError("Expected a bound type definition")
        }
    }

    internal func resolve(_ index: TypeDefTable.RowIndex) throws -> TypeDefinition {
        typeDefinitions[Int(index.zeroBased)]
    }

    internal func resolve(_ index: TypeRefTable.RowIndex) throws -> TypeDefinition {
        let row = moduleFile.typeRefTable[index]
        let name = moduleFile.resolve(row.typeName)
        let namespace = moduleFile.resolve(row.typeNamespace)
        switch row.resolutionScope {
            case let .module(index):
                // Assume single-module assembly
                guard index?.zeroBased == 0 else { break }
                return try resolveTypeDefinition(namespace: namespace, name: name)!
            case let .assemblyRef(index):
                guard let index = index else { break }
                return try resolve(index).resolveTypeDefinition(namespace: namespace, name: name)!
            default:
                fatalError("Not implemented: resolution scope \(row.resolutionScope)")
        }
        fatalError("Not implemented: null resolution scope")
    }

    internal func resolve(_ index: TypeSpecTable.RowIndex, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) throws -> TypeNode {
        let typeSpecRow = moduleFile.typeSpecTable[index]
        let signatureBlob = moduleFile.resolve(typeSpecRow.signature)
        let typeSig = try TypeSig(blob: signatureBlob)
        return try resolve(typeSig, typeContext: typeContext, methodContext: methodContext)
    }

    internal func resolve(_ index: AssemblyRefTable.RowIndex) throws -> Assembly {
        let row = moduleFile.assemblyRefTable[index]
        let identity = AssemblyIdentity(fromRow: row, in: moduleFile)
        return try context.load(identity: identity)
    }

    internal func resolve(_ typeSig: TypeSig, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) throws -> TypeNode {
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
                    let genericArgs = try genericArgs.map { try resolve($0, typeContext: typeContext, methodContext: methodContext) }
                    switch index {
                        case let .typeDef(index): return try resolve(index!).bindType(genericArgs: genericArgs).asNode
                        case let .typeRef(index): return try resolve(index!).bindType(genericArgs: genericArgs).asNode
                        default: fatalError("Not implemented: unexpected generic type reference")
                    }
                }
                else {
                    return try resolve(index)!
                }

            case let .szarray(_, of: element):
                return .array(of: try resolve(element, typeContext: typeContext, methodContext: methodContext))

            case let .ptr(_, to: pointeeSig):
                let pointeeNode: TypeNode?
                if case .void = pointeeSig { pointeeNode = nil }
                else { pointeeNode = try resolve(pointeeSig, typeContext: typeContext, methodContext: methodContext) }
                return .pointer(to: pointeeNode)

            case let .genericParam(index, method):
                if method {
                    guard let methodContext else { fatalError("Missing a method context for resolving a generic parameter reference") }
                    return .genericParam(methodContext.genericParams[Int(index)])
                }
                else {
                    guard let typeContext else { fatalError("Missing a type context for resolving a generic parameter reference") }
                    return .genericParam(typeContext.genericParams[Int(index)])
                }

            default: fatalError("Not implemented: resolve \(typeSig)")
        }
    }

    internal func resolve(_ methodDefRowIndex: MethodDefTable.RowIndex) throws -> Method {
        guard let typeDefRowIndex = moduleFile.typeDefTable.findMethodOwner(methodDefRowIndex) else {
            fatalError("No owner found for method \(methodDefRowIndex)")
        }

        let methodIndex = methodDefRowIndex.zeroBased - moduleFile.typeDefTable[typeDefRowIndex].methodList!.zeroBased
        return try resolve(typeDefRowIndex).methods[Int(methodIndex)]
    }

    internal func resolveMethod(_ index: MemberRefTable.RowIndex) throws -> Method? {
        let row = moduleFile.memberRefTable[index]

        guard let typeDefinition: TypeDefinition = try {
            switch row.class {
                case let .typeDef(index):
                    guard let index = index else { return nil }
                    return try resolve(index)
                case let .typeRef(index):
                    guard let index = index else { return nil }
                    return try resolve(index)
                default:
                    fatalError("Not implemented: Resolving \(row.class)")
            }
        }() else { return nil }

        let name = moduleFile.resolve(row.name)
        let sig = try MethodSig(blob: moduleFile.resolve(row.signature), isRef: true)

        let genericArity: Int = {
            switch sig.callingConv {
                case let .default(genericArity): return Int(genericArity)
                // TODO: Figure out how method resolution works with varargs
                default: return 0
            }
        }()

        let method = try typeDefinition.findMethod(
            name: name,
            static: !sig.thisParam.isPresent,
            genericArity: genericArity,
            paramTypes: sig.params.map { try resolve($0.type) })
        guard let method else { return nil }

        func matches(_ param: ParamBase, _ paramSig: ParamSig) throws -> Bool {
            // TODO: Compare CustomMods
            try param.isByRef == paramSig.byRef && param.type == resolve(paramSig.type)
        }

        guard (try? matches(method.returnParam, sig.returnParam)) == true else { return nil }

        // TODO: Compare param byrefs and custom mods
        return method
    }

    internal func resolve(_ codedIndex: CustomAttributeType) throws -> Method? {
        switch codedIndex {
            case .methodDef(let index):
                guard let index = index else { return nil }
                return try resolve(index)
            case .memberRef(let index):
                guard let index = index else { return nil }
                return try resolveMethod(index)
        }
    }
}
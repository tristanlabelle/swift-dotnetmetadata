import DotNetMetadataFormat

extension Assembly {
    internal func resolveTypeToken(_ metadataToken: MetadataToken, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) throws -> TypeNode? {
        guard let rowIndex = metadataToken.rowIndex else { return nil }
        switch metadataToken.tableID {
            case .typeDef:
                return try resolveTypeDef(rowIndex: rowIndex).bindNode()
            case .typeRef:
                return try resolveTypeRef(rowIndex: rowIndex).bindNode()
            case .typeSpec:
                return try resolveTypeSpec(rowIndex: rowIndex, typeContext: typeContext, methodContext: methodContext)
            default:
                fatalError("Not implemented: \(metadataToken)")
        }
    }

    internal func resolveTypeDefOrRef(_ codedIndex: CodedIndices.TypeDefOrRef, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) throws -> TypeNode? {
        guard let rowIndex = codedIndex.rowIndex else { return nil }
        switch try codedIndex.tag {
            case .typeDef:
                return try resolveTypeDef(rowIndex: rowIndex).bindNode()
            case .typeRef:
                return try resolveTypeRef(rowIndex: rowIndex).bindNode()
            case .typeSpec:
                return try resolveTypeSpec(rowIndex: rowIndex, typeContext: typeContext, methodContext: methodContext)
        }
    }

    internal func resolveTypeDefOrRefToBoundType(_ codedIndex: CodedIndices.TypeDefOrRef, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) throws -> BoundType? {
        guard let typeNode = try resolveTypeDefOrRef(codedIndex, typeContext: typeContext, methodContext: methodContext) else { return nil }
        switch typeNode {
            case .bound(let bound): return bound
            default: fatalError("Expected a bound type definition")
        }
    }

    internal func resolveTypeDef(rowIndex: TableRowIndex) throws -> TypeDefinition {
        typeDefinitions[Int(rowIndex.zeroBased)]
    }

    internal func resolveTypeRef(rowIndex: TableRowIndex) throws -> TypeDefinition {
        let row = moduleFile.typeRefTable[rowIndex]
        let name = moduleFile.resolve(row.typeName)
        let namespace = moduleFile.resolve(row.typeNamespace)
        guard let resolutionScopeRowIndex = row.resolutionScope.rowIndex else {
            fatalError("Not implemented: null resolution scope")
        }

        switch try row.resolutionScope.tag {
            case .module:
                // Assume single-module assembly
                assert(resolutionScopeRowIndex.zeroBased == 0)
                return try resolveTypeDefinition(namespace: namespace, name: name)!
            case .assemblyRef:
                guard let assemblyRefRowIndex = row.resolutionScope.rowIndex else {
                    throw DotNetMetadataFormat.InvalidFormatError.tableConstraint
                }
                let assemblyReference = try resolveAssemblyRef(rowIndex: assemblyRefRowIndex)
                return try context.resolveType(
                    assembly: assemblyReference.identity,
                    assemblyFlags: assemblyReference.flags,
                    name: TypeName(namespace: namespace, shortName: name))
            default:
                fatalError("Not implemented: resolution scope \(row.resolutionScope)")
        }
    }

    internal func resolveTypeSpec(rowIndex: TableRowIndex, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) throws -> TypeNode {
        let typeSpecRow = moduleFile.typeSpecTable[rowIndex]
        let signatureBlob = moduleFile.resolve(typeSpecRow.signature)
        let typeSig = try TypeSig(blob: signatureBlob)
        return try resolveTypeSig(typeSig, typeContext: typeContext, methodContext: methodContext)
    }

    internal func resolveAssemblyRef(rowIndex: TableRowIndex) throws -> AssemblyReference {
        self.references[Int(rowIndex.zeroBased)]
    }

    internal func resolveTypeSig(_ typeSig: TypeSig, typeContext: TypeDefinition? = nil, methodContext: Method? = nil) throws -> TypeNode {
        switch typeSig {
            case .void: return try context.coreLibrary.systemVoid.bindNode()
            case .boolean: return try context.coreLibrary.systemBoolean.bindNode()
            case .char: return try context.coreLibrary.systemChar.bindNode()

            case let .integer(size, signed):
                return try context.coreLibrary.getSystemInt(size, signed: signed).bindNode()

            case let .real(double):
                return try (double ? context.coreLibrary.systemDouble : context.coreLibrary.systemSingle).bindNode()

            case .string: return try context.coreLibrary.systemString.bindNode()
            case .object: return try context.coreLibrary.systemObject.bindNode()

            case let .defOrRef(codedIndex, _, genericArgs):
                if genericArgs.count > 0 {
                    let genericArgs = try genericArgs.map {
                        try resolveTypeSig($0, typeContext: typeContext, methodContext: methodContext)
                    }
                    let rowIndex = codedIndex.rowIndex!
                    switch try codedIndex.tag {
                        case .typeDef: return try resolveTypeDef(rowIndex: rowIndex).bindType(genericArgs: genericArgs).asNode
                        case .typeRef: return try resolveTypeRef(rowIndex: rowIndex).bindType(genericArgs: genericArgs).asNode
                        default: fatalError("Not implemented: unexpected generic type reference")
                    }
                }
                else {
                    return try resolveTypeDefOrRef(codedIndex)!
                }

            case let .array(of: elementSig, shapeSig):
                let element = try resolveTypeSig(elementSig, typeContext: typeContext, methodContext: methodContext)
                return .array(of: element, shape: ArrayShape(shapeSig))

            case let .szarray(_, of: element):
                return .array(of: try resolveTypeSig(element, typeContext: typeContext, methodContext: methodContext))

            case let .ptr(_, to: pointeeSig):
                let pointeeNode: TypeNode?
                if case .void = pointeeSig { pointeeNode = nil }
                else { pointeeNode = try resolveTypeSig(pointeeSig, typeContext: typeContext, methodContext: methodContext) }
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

    internal func resolveMethodDef(rowIndex: TableRowIndex) throws -> Method {
        guard let typeDefRowIndex = moduleFile.typeDefTable.findMethodDefOwner(rowIndex: rowIndex) else {
            fatalError("No owner found for method \(rowIndex)")
        }

        let firstTypeDefMethodRowIndex = moduleFile.typeDefTable[typeDefRowIndex].methodList.index!
        let methodIndex = rowIndex.zeroBased - firstTypeDefMethodRowIndex.zeroBased
        return try resolveTypeDef(rowIndex: typeDefRowIndex).methods[Int(methodIndex)]
    }

    internal func resolveMethodRef(rowIndex: TableRowIndex) throws -> Method? {
        let row = moduleFile.memberRefTable[rowIndex]

        guard let typeDefinition: TypeDefinition = try {
            guard let classRowIndex = row.class.rowIndex else { return nil }
            switch try row.class.tag {
                case .typeDef:
                    return try resolveTypeDef(rowIndex: classRowIndex)
                case .typeRef:
                    return try resolveTypeRef(rowIndex: classRowIndex)
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
            paramTypes: sig.params.map { try resolveTypeSig($0.type) })
        guard let method else { return nil }

        func matches(_ param: ParamBase, _ paramSig: ParamSig) throws -> Bool {
            // TODO: Compare CustomMods
            try param.isByRef == paramSig.byRef && param.type == resolveTypeSig(paramSig.type)
        }

        guard (try? matches(method.returnParam, sig.returnParam)) == true else { return nil }

        // TODO: Compare param byrefs and custom mods
        return method
    }

    internal func resolveCustomAttributeType(_ codedIndex: CodedIndices.CustomAttributeType) throws -> Method? {
        guard let rowIndex = codedIndex.rowIndex else { return nil }
        switch try codedIndex.tag {
            case .methodDef:
                return try resolveMethodDef(rowIndex: rowIndex)
            case .memberRef:
                return try resolveMethodRef(rowIndex: rowIndex)
        }
    }
}
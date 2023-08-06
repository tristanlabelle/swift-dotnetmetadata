import DotNetMetadataFormat

extension ModuleFile {
    func getTypeDefinitionKind(_ tableRow: TypeDefTable.Row, isMscorlib: Bool) -> TypeDefinitionKind {
        if tableRow.flags.contains(.interface) {
            return .interface
        }

        // We must check the base type, but before doing so exclude special cases
        if isMscorlib && resolve(tableRow.typeNamespace) == "System" {
            switch resolve(tableRow.typeName) {
                case "Object": return .class
                case "Enum": return .class
                case "MulticastDelegate": return .class
                default: break
            }
        }

        return getTypeDefinitionFromBase(tableRow.extends, isMscorlib: isMscorlib)
    }

    private func getTypeDefinitionFromBase(_ extends: TypeDefOrRef, isMscorlib: Bool) -> TypeDefinitionKind {
        let systemTypeName: String
        switch extends {
            case let .typeDef(index):
                guard let index else { return .class }
                guard isMscorlib else { return .class }
                let typeDefRow = typeDefTable[index]
                guard resolve(typeDefRow.typeNamespace) == "System" else { return .class }
                systemTypeName = resolve(typeDefRow.typeName)
            case let .typeRef(index):
                guard let index else { return .class }
                let typeRefRow = typeRefTable[index]
                guard resolve(typeRefRow.typeNamespace) == "System" else { return .class }
                guard getAssemblyName(resolutionScope: typeRefRow.resolutionScope) == Mscorlib.name else { return .class }
                systemTypeName = resolve(typeRefRow.typeName)
            case .typeSpec:
                // Assume no special base type can be referred through a typeSpec
                return .class
        }

        switch systemTypeName {
            case "ValueType": return .struct
            case "Enum": return .enum
            case "Delegate", "MulticastDelegate": return .delegate
            default: return .class
        }
    }

    private func getAssemblyName(resolutionScope: ResolutionScope) -> String? {
        switch resolutionScope {
            case .module, .moduleRef: return nil
            case let .assemblyRef(index):
                guard let index else { return nil }
                let assemblyRefRow = assemblyRefTable[index]
                return resolve(assemblyRefRow.name)
            case let .typeRef(index):
                guard let index else { return nil }
                let typeRefRow = typeRefTable[index]
                return getAssemblyName(resolutionScope: typeRefRow.resolutionScope)
        }
    }
}
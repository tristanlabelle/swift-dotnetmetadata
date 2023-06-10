import WinMD

extension Database {
    func getTypeDefinitionKind(_ tableRow: WinMD.TypeDef, isMscorlib: Bool) -> TypeDefinitionKind {
        if tableRow.flags.contains(.interface) {
            return .interface
        }

        // We must check the base type, but before doing so exclude special cases
        if isMscorlib && heaps.resolve(tableRow.typeNamespace) == "System" {
            switch heaps.resolve(tableRow.typeName) {
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
                let typeDefRow = tables.typeDef[index]
                guard heaps.resolve(typeDefRow.typeNamespace) == "System" else { return .class }
                systemTypeName = heaps.resolve(typeDefRow.typeName)
            case let .typeRef(index):
                guard let index else { return .class }
                let typeRefRow = tables.typeRef[index]
                guard heaps.resolve(typeRefRow.typeNamespace) == "System" else { return .class }
                guard getAssemblyName(resolutionScope: typeRefRow.resolutionScope) == Mscorlib.name else { return .class }
                systemTypeName = heaps.resolve(typeRefRow.typeName)
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

    private func getAssemblyName(resolutionScope: ResolutionScope) -> String?
    {
        switch resolutionScope {
            case .module, .moduleRef: return nil
            case let .assemblyRef(index):
                guard let index else { return nil }
                let assemblyRefRow = tables.assemblyRef[index]
                return heaps.resolve(assemblyRefRow.name)
            case let .typeRef(index):
                guard let index else { return nil }
                let typeRefRow = tables.typeRef[index]
                return getAssemblyName(resolutionScope: typeRefRow.resolutionScope)
        }
    }
}
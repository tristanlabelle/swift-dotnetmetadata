import DotNetMetadataFormat

extension ModuleFile {
    func getTypeDefinitionKind(_ tableRow: TypeDefTable.Row) throws -> TypeDefinitionKind {
        if tableRow.flags.contains(.interface) {
            return .interface
        }

        // We must check the base type, but before doing so exclude special cases
        if resolve(tableRow.typeNamespace) == "System" {
            switch resolve(tableRow.typeName) {
                case "Object": return .class
                case "Enum": return .class
                case "MulticastDelegate": return .class
                default: break
            }
        }

        return try getTypeDefinitionFromBase(tableRow.extends)
    }

    private func getTypeDefinitionFromBase(_ extends: CodedIndices.TypeDefOrRef) throws -> TypeDefinitionKind {
        let systemTypeName: String
        guard let rowIndex = extends.rowIndex else { return .class }
        switch try extends.tag {
            case .typeDef:
                let typeDefRow = typeDefTable[rowIndex]
                guard resolve(typeDefRow.typeNamespace) == "System" else { return .class }
                systemTypeName = resolve(typeDefRow.typeName)
            case .typeRef:
                let typeRefRow = typeRefTable[rowIndex]
                guard resolve(typeRefRow.typeNamespace) == "System" else { return .class }
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
}
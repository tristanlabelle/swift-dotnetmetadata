public enum TypeDefinitionKind: Hashable {
    case `class`
    case interface
    case delegate
    case `struct`
    case `enum`
}

extension TypeDefinitionKind {
    public var isReferenceType: Bool {
        switch self {
            case .class, .interface, .delegate: return true
            case .struct, .enum: return false
        }
    }

    public var isValueType: Bool { !isReferenceType }
}
public enum TypeDefinitionKind {
    case `class`
    case interface
    case delegate
    case `struct`
    case `enum`
}

extension TypeDefinitionKind {
    public var metatype: TypeDefinition.Type {
        switch self {
            case .class: return ClassDefinition.self
            case .interface: return InterfaceDefinition.self
            case .delegate: return DelegateDefinition.self
            case .struct: return StructDefinition.self
            case .enum: return EnumDefinition.self
        }
    }
}

public final class ClassDefinition: TypeDefinition {
    public override var kind: TypeDefinitionKind { .class }
}

public final class InterfaceDefinition: TypeDefinition {
    public override var kind: TypeDefinitionKind { .interface }
}

public final class DelegateDefinition: TypeDefinition {
    public override var kind: TypeDefinitionKind { .delegate }
}

public final class StructDefinition: TypeDefinition {
    public override var kind: TypeDefinitionKind { .struct }
}

public final class EnumDefinition: TypeDefinition {
    public override var kind: TypeDefinitionKind { .enum }
}
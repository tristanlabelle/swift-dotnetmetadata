public enum Type {
    case simple(TypeDefinition)
    indirect case array(Type)
    indirect case genericInstance(TypeDefinition, [Type])
    case genericArgument(GenericParam)
    indirect case pointer(Type)
}
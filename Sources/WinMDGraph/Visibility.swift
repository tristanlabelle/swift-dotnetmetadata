public enum Visibility {
    case compilerControlled
    case `private`
    case assembly // internal
    case familyAndAssembly // private protected
    case familyOrAssembly // protected internal
    case family // protected
    case `public`
}
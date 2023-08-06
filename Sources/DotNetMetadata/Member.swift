public class Member {
    internal init() {}

    public var definingType: TypeDefinition { fatalError() }
    public var name: String { fatalError() }
    public var visibility: Visibility { fatalError() }
    public var isStatic: Bool { fatalError() }
}
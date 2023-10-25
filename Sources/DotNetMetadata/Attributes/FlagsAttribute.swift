/// Indicates that an enumeration can be treated as a bit field; that is, a set of flags.
public enum FlagsAttribute: AttributeType {
    public static var namespace: String? { "System." }
    public static var name: String { "FlagsAttribute" }
    public static var validOn: AttributeTargets { .enum }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { false }

    public static func decode(_ attribute: Attribute) throws -> Void {}
}

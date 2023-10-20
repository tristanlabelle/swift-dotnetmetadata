public enum ComImportAttribute: AttributeType {
    public static var namespace: String { "System.Runtime.InteropServices" }
    public static var name: String { "ComImportAttribute" }
    public static var validOn: AttributeTargets { .class | .interface }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { false }

    public static func decode(_ attribute: Attribute) throws -> Void { () }
}

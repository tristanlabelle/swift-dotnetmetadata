public struct MethodSignature {
    public var hasThis: Bool
    public var params: [Param]
    public var returnParam: Param

    public struct Param {
        public var customMods: [CustomModifier]
        public var byRef: Bool
        public var type: TypeNode
    }

    public struct CustomModifier {
        public var isRequired: Bool
        public var type: TypeNode
    }
}
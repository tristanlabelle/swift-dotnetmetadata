
public enum MemberKey {
    case namespace(name: String)
    case type(fullName: String)
    case field(typeFullName: String, name: String)
    case method(typeFullName: String, name: String, params: [Param], conversionTarget: Param?)
    case property(typeFullName: String, name: String, params: [Param])
    case event(typeFullName: String, name: String)
    case unresolved(String)

    public struct Param {
        public var isByRef: Bool
        public var type: ParamType
        public var customModifiers: [ParamType]

        public init(type: ParamType, isByRef: Bool = false, customModifiers: [ParamType] = []) {
            self.type = type
            self.isByRef = isByRef
            self.customModifiers = customModifiers
        }
    }

    public enum ParamType {
        case bound(fullName: String, genericArgs: [ParamType] = [])
        indirect case array(element: ParamType)
        indirect case pointer(element: ParamType)
        case genericArg(index: Int, kind: GenericArgKind)
        // case array(element: ParamType, shape: [(lowerBound: Int, size: Int)])
    }

    public enum GenericArgKind {
        case type
        case method
    }
}
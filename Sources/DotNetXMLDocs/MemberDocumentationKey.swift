
public enum MemberDocumentationKey: Hashable {
    public static let constructorName: String = "#ctor"

    case namespace(name: String)
    case type(fullName: String)
    case field(declaringType: String, name: String)
    case method(declaringType: String, name: String, params: [Param] = [], conversionTarget: Param? = nil)
    case property(declaringType: String, name: String, params: [Param] = [])
    case event(declaringType: String, name: String)
    case unresolved(String)

    public struct Param: Hashable {
        public var isByRef: Bool
        public var type: ParamType
        public var customModifiers: [ParamType]

        public init(type: ParamType, isByRef: Bool = false, customModifiers: [ParamType] = []) {
            self.type = type
            self.isByRef = isByRef
            self.customModifiers = customModifiers
        }

        public init(typeFullName: String, isByRef: Bool = false) {
            self.init(type: .bound(fullName: typeFullName), isByRef: isByRef)
        }
    }

    public enum ParamType: Hashable {
        case bound(fullName: String, genericArgs: [ParamType] = [])
        indirect case array(of: ParamType)
        indirect case pointer(to: ParamType)
        case genericArg(index: Int, kind: GenericArgKind)
        // case array(of: ParamType, shape: [(lowerBound: Int, size: Int)])
    }

    public enum GenericArgKind: Hashable {
        case type
        case method
    }
}
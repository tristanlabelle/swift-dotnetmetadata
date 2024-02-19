import DotNetMetadata

/// Indicates the threading model of a Windows Runtime component.
public struct MarshalingBehaviorAttribute: AttributeType {
    public var type: MarshalingType

    public init(type: MarshalingType) {
        self.type = type
    }

    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "MarshalingBehaviorAttribute" }
    public static var validOn: AttributeTargets { .class }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Self {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .int32(let value) = constant,
            let marshalingType = MarshalingType(rawValue: value) else { throw InvalidMetadataError.attributeArguments }
        return .init(type: marshalingType)
    }
}

public enum MarshalingType: Int32, Hashable {
    /// The class prevents marshaling on all interfaces.
    case none = 1
    /// The class marshals and unmarshals to the same pointer value on all interfaces.
    case agile = 2
    /// The class does not implement IMarshal or forwards to CoGetStandardMarshal on all interfaces.
    case standard = 3
}
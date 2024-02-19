import DotNetMetadata

/// Indicates the threading model of a Windows Runtime component.
public struct ThreadingAttribute: AttributeType {
    public var model: ThreadingModel

    public init(_ model: ThreadingModel) {
        self.model = model
    }

    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "ThreadingAttribute" }
    public static var validOn: AttributeTargets { .class }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> Self {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .int32(let value) = constant,
            let threadingModel = ThreadingModel(rawValue: value) else { throw InvalidMetadataError.attributeArguments }
        return .init(threadingModel)
    }
}

public enum ThreadingModel: Int32, Hashable {
    /// Single-threaded apartment
    case sta = 1
    /// Multithreaded apartment
    case mta = 2
    /// Both single-threaded and multithreaded apartments
    case both = 3
}
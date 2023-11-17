import DotNetMetadata

/// Indicates the threading model of a Windows Runtime component.
public enum ThreadingAttribute: AttributeType {
    public static var namespace: String? { "Windows.Foundation.Metadata" }
    public static var name: String { "ThreadingAttribute" }
    public static var validOn: AttributeTargets { .class }
    public static var allowMultiple: Bool { false }
    public static var inherited: Bool { true }

    public static func decode(_ attribute: Attribute) throws -> ThreadingModel {
        let arguments = try attribute.arguments
        guard arguments.count == 1,
            case .constant(let constant) = arguments[0],
            case .int32(let value) = constant,
            let threadingModel = ThreadingModel(rawValue: value) else { throw InvalidMetadataError.attributeArguments }
        return threadingModel
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
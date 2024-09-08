/// Represents the name of a .NET Type, including its namespace and nested type names.
public struct TypeName: Hashable, CustomStringConvertible {
    public static let namespaceSeparator: Character = "."
    public static let nestedTypeSeparator: Character = "/"
    public static let genericAritySeparator: Character = "`"

    public let namespace: String?
    /// The short type name and any nested type names.
    public let shortNames: [String] // Invariant: non-empty
    // TODO: Splitoff generic arity?

    public init(namespace: String?, shortNames: [String]) {
        assert(!shortNames.isEmpty)
        self.namespace = namespace
        self.shortNames = shortNames
    }

    public init(namespace: String?, shortName: String) {
        assert(!shortName.contains(Self.namespaceSeparator))
        assert(!shortName.contains(Self.nestedTypeSeparator))
        self.namespace = namespace
        self.shortNames = [shortName]
    }

    public init(namespace: String?, outermostShortName: String, nestedNames: [String]) {
        self.init(namespace: namespace, shortNames: [outermostShortName] + nestedNames)
    }

    public init(fullName: String) {
        let namespaceEnd = fullName.lastIndex(of: Self.namespaceSeparator)
        let shortNamesStart = namespaceEnd.map { fullName.index(after: $0) } ?? fullName.startIndex
        self.init(
            namespace: namespaceEnd.map { String(fullName[...$0]) },
            shortNames: fullName[shortNamesStart...].split(separator: Self.nestedTypeSeparator).map(String.init))
    }

    public var outermostShortName: String { shortNames.first! }
    public var nestedNames: ArraySlice<String> { shortNames.dropFirst() }

    public var fullName: String {
        var result: String = ""
        if let namespace {
            result = namespace
            result.append(TypeName.namespaceSeparator)
        }

        for (index, shortName) in shortNames.enumerated() {
            if index > 0 { result.append(Self.nestedTypeSeparator) }
            result += shortName
        }

        return result
    }

    public var description: String { fullName }

    public static func toFullName(namespace: String?, shortName: String) -> String {
        if let namespace { return "\(namespace)\(namespaceSeparator)\(shortName)" }
        else { return shortName }
    }

    public static func toFullName(namespace: String?, outermostShortName: String, nestedNames: [String]) -> String {
        Self(namespace: namespace, outermostShortName: outermostShortName, nestedNames: nestedNames).fullName
    }

    public static func trimGenericArity(_ name: String) -> String {
        guard let genericAritySeparatorIndex = name.lastIndex(of: genericAritySeparator) else { return name }
        return String(name[..<genericAritySeparatorIndex])
    }
}
/// Represents the name of a .NET Type, including its namespace and nested type names.
public struct TypeName: Hashable, CustomStringConvertible {
    public static let namespaceSeparator: Character = "."
    public static let nestedTypeSeparator: Character = "/"
    public static let genericAritySeparator: Character = "`"

    public let namespace: String?
    public let outermostShortName: String
    public let nestedNames: [String]

    public init(namespace: String?, outermostShortName: String, nestedNames: [String]) {
        assert(!outermostShortName.contains(Self.namespaceSeparator))
        assert(!outermostShortName.contains(Self.nestedTypeSeparator))
        self.namespace = namespace
        self.outermostShortName = outermostShortName
        self.nestedNames = nestedNames
    }

    public init(namespace: String?, shortName: String) {
        self.init(namespace: namespace, outermostShortName: shortName, nestedNames: [])
    }

    public init(fullName: String) {
        let namespaceEnd = fullName.lastIndex(of: Self.namespaceSeparator)
        let shortNamesStart = namespaceEnd.map { fullName.index(after: $0) } ?? fullName.startIndex
        let shortNamesPart = fullName[shortNamesStart...]
        if let outermostShortNameEnd = shortNamesPart.firstIndex(of: Self.nestedTypeSeparator) {
            let nestedNamesPart = shortNamesPart[shortNamesPart.index(after: outermostShortNameEnd)...]
            self.init(
                namespace: namespaceEnd.map { String(fullName[...$0]) },
                outermostShortName: String(shortNamesPart[..<outermostShortNameEnd]),
                nestedNames: nestedNamesPart.split(separator: Self.nestedTypeSeparator).map(String.init))
        }
        else {
            self.init(
                namespace: namespaceEnd.map { String(fullName[..<$0]) },
                shortName: String(shortNamesPart))
        }
    }

    public var fullName: String {
        var result: String = ""
        if let namespace {
            result = namespace
            result.append(TypeName.namespaceSeparator)
        }
        result.append(outermostShortName)

        for nestedName in nestedNames {
            result.append(Self.nestedTypeSeparator)
            result += nestedName
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
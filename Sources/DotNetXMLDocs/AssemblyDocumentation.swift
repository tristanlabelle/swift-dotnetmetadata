public struct AssemblyDocumentation: DocumentationSink {
    public var name: String? = nil
    public var members: [MemberKey: MemberEntry] = [:]

    public mutating func setAssembly(name: String) {
        self.name = name
    }

    public mutating func addMember(key: MemberKey, entry: MemberEntry) {
        members[key] = entry
    }
}
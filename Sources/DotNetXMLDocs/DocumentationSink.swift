public protocol DocumentationSink {
    mutating func setAssembly(name: String)
    mutating func addMember(key: MemberKey, entry: MemberEntry)
}
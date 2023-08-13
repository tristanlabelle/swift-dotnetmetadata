public struct DocumentationFile {
    public var assemblyName: String
    public var members: [MemberKey: MemberEntry] = [:]

    public init(assemblyName: String) {
        self.assemblyName = assemblyName
    }
}
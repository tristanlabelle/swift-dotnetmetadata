public struct AssemblyDocumentation {
    public var assemblyName: String
    public var members: [MemberDocumentationKey: MemberDocumentation] = [:]

    public init(assemblyName: String) {
        self.assemblyName = assemblyName
    }
}
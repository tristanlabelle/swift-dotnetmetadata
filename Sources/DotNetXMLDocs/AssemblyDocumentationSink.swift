public protocol AssemblyDocumentationSink {
    mutating func setAssemblyName(_ name: String)
    mutating func addMember(_ member: MemberDocumentation, forKey key: MemberDocumentationKey)
}
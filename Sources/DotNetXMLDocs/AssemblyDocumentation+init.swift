import FoundationXML
import struct Foundation.URL

extension AssemblyDocumentation {
    public init(readingFileAtPath filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        let document = try XMLDocument(contentsOf: url, options: [])
        try self.init(parsing: document)
    }

    public init(parsing document: XMLDocument) throws {
        var builder = Builder()
        Self.parse(document: document, to: &builder)
        guard let result = builder.result else { throw DocumentationFormatError() }
        self = result
    }

    fileprivate struct Builder: AssemblyDocumentationSink {
        var result: AssemblyDocumentation?

        mutating func setAssemblyName(_ name: String) {
            guard result == nil else { return }
            self.result = AssemblyDocumentation(assemblyName: name)
        }

        mutating func addMember(_ member: MemberDocumentation, forKey key: MemberDocumentationKey) {
            guard result != nil else { return }
            result!.members[key] = member
        }
    }
}

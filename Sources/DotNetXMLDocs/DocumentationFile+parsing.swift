import FoundationXML
import struct Foundation.URL

extension DocumentationFile {
    public init(readingFileAtPath filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        let document = try XMLDocument(contentsOf: url, options: [])
        try self.init(parsing: document)
    }

    public init(parsing document: XMLDocument) throws {
        var builder = Builder()
        parse(document: document, to: &builder)
        guard let result = builder.result else { throw InvalidFormatError() }
        self = result
    }

    fileprivate struct Builder: DocumentationSink {
        var result: DocumentationFile?

        mutating func setAssembly(name: String) {
            guard result == nil else { return }
            self.result = DocumentationFile(assemblyName: name)
        }

        mutating func addMember(key: MemberKey, entry: MemberEntry) {
            guard result != nil else { return }
            result!.members[key] = entry
        }
    }
}

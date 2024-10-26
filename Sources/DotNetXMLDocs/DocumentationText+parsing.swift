import FoundationXML
import struct Foundation.URL

extension DocumentationText {
    public init(parsing nodes: [XMLNode]) throws {
        try self.init(nodes: nodes.map { try .init(parsing: $0) })
    }
}

extension DocumentationText.Node {
    public init(parsing node: XMLNode) throws {
        self = try Self.parse(node: node)
    }

    private static func parse(node: XMLNode) throws -> Self {
        guard node.kind != .text else { return .plain(node.stringValue ?? "") }

        guard let element = node as? XMLElement else { throw DocumentationFormatError() }
        switch element.name! {
            // Blocks
            case "para": return .paragraph(try DocumentationText(parsing: element.children ?? []))
            case "code": return .codeBlock(element.xmlString)
            case "list":
                let type = element.attribute(forName: "type")?.stringValue.flatMap { ListType(rawValue: $0) }
                let items = try element.elements(forName: "item").map { try DocumentationText(parsing: $0.children ?? []) }
                return .list(type: type, items: items)
            case "example": return .example(try DocumentationText(parsing: element.children ?? []))

            // Inline
            case "c": return .codeSpan(text: element.xmlString) // TODO: Handle properly
            case "paramref", "typeparamref":
                let name = element.attribute(forName: "name")?.stringValue ?? ""
                return element.name == "paramref" ? .paramReference(name: name) : .typeParamReference(name: name)
            case "see", "seealso":
                let cref = element.attribute(forName: "cref")?.stringValue ?? ""
                let url = element.attribute(forName: "url")?.stringValue.flatMap { URL(string: $0) }
                let also = element.name == "seealso"
                return .see(codeReference: try MemberDocumentationKey(parsing: cref), url: url, also: also)

            default: 
                // TODO: Handle unknown elements
                throw DocumentationFormatError()
        }
    }
}
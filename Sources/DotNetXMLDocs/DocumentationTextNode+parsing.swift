import FoundationXML
import struct Foundation.URL

extension DocumentationTextNode {
    public init(parsing nodes: [XMLNode]) throws {
        self = nodes.count == 1 ? try Self.parse(node: nodes[0]) : .sequence(try nodes.map(Self.parse))
    }

    public init(parsing node: XMLNode) throws {
        self = try DocumentationTextNode.parse(node: node)
    }

    fileprivate static func parse(node: XMLNode) throws -> DocumentationTextNode {
        if node.kind == .text {
            return .plain(node.stringValue ?? "")
        }
        else if let element = node as? XMLElement {
            switch element.name! {
                // Blocks
                case "para": return .paragraph(try DocumentationTextNode(parsing: element.children ?? []))
                case "code": return .codeBlock(element.xmlString) // TODO: Handle properly
                case "list":
                    let items = try element.elements(forName: "item").map { try DocumentationTextNode(parsing: $0.children ?? []) }
                    return .list(items: items)
                case "example": return .paragraph(try DocumentationTextNode(parsing: element.children ?? []))

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
        else {
            throw DocumentationFormatError()
        }
    }
}
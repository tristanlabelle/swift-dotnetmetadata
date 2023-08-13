import FoundationXML
import struct Foundation.URL

extension TextNode {
    public init(parsing nodes: [XMLNode]) throws {
        self = nodes.count == 1 ? try Self.parse(node: nodes[0]) : .sequence(try nodes.map(Self.parse))
    }

    public init(parsing node: XMLNode) throws {
        self = try TextNode.parse(node: node)
    }

    fileprivate static func parse(node: XMLNode) throws -> TextNode {
        if node.kind == .text {
            return .plain(node.stringValue ?? "")
        }
        else if let element = node as? XMLElement, let elementName = element.name {
            switch elementName {
                // Blocks
                case "para": return .paragraph(try TextNode(parsing: element.children ?? []))
                case "code": return .codeBlock(element.xmlString) // TODO: Handle properly
                case "list":
                    let items = try element.elements(forName: "item").map { try TextNode(parsing: $0.children ?? []) }
                    return .list(items: items)
                case "example": return .paragraph(try TextNode(parsing: element.children ?? []))

                // Inline
                case "c": return .codeSpan(text: element.xmlString) // TODO: Handle properly
                case "paramref", "typeparamref":
                    let name = element.attribute(forName: "name")?.stringValue ?? ""
                    return elementName == "paramref" ? .paramReference(name: name) : .typeParamReference(name: name)
                case "see", "seealso":
                    let cref = element.attribute(forName: "cref")?.stringValue ?? ""
                    let url = element.attribute(forName: "url")?.stringValue.flatMap { URL(string: $0) }
                    let also = elementName == "seealso"
                    return .see(codeReference: try MemberKey(parsing: cref), url: url, also: also)

                default: 
                    // TODO: Handle unknown elements
                    throw InvalidFormatError()
            }
        }
        else {
            throw InvalidFormatError()
        }
    }
}
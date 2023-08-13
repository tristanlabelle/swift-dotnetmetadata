import FoundationXML

extension MemberEntry {
    public init(parsing element: XMLElement) {
        for child in element.children ?? [] {
            guard let element = child as? XMLElement else { continue }

            switch element.name {
                case "summary": summary = try? TextNode(parsing: element.children ?? [])
                case "remarks": remarks = try? TextNode(parsing: element.children ?? [])
                case "value": value = try? TextNode(parsing: element.children ?? [])
                case "returns": returns = try? TextNode(parsing: element.children ?? [])
                case "typeparam":
                    if let name = element.attribute(forName: "name")?.stringValue,
                        let textNode = try? TextNode(parsing: element.children ?? []) {
                        typeParams[name] = textNode
                    }
                case "param":
                    if let name = element.attribute(forName: "name")?.stringValue,
                        let textNode = try? TextNode(parsing: element.children ?? []) {
                        params[name] = textNode
                    }
                default: break
            }
        }
    }
}
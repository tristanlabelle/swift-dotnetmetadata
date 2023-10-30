import FoundationXML

extension MemberDocumentation {
    public init(parsing element: XMLElement) {
        for child in element.children ?? [] {
            guard let element = child as? XMLElement else { continue }

            switch element.name {
                case "summary": summary = try? DocumentationTextNode(parsing: element.children ?? [])
                case "remarks": remarks = try? DocumentationTextNode(parsing: element.children ?? [])
                case "value": value = try? DocumentationTextNode(parsing: element.children ?? [])
                case "returns": returns = try? DocumentationTextNode(parsing: element.children ?? [])
                case "typeparam":
                    if let name = element.attribute(forName: "name")?.stringValue,
                        let DocumentationTextNode = try? DocumentationTextNode(parsing: element.children ?? []) {
                        typeParams[name] = DocumentationTextNode
                    }
                case "param":
                    if let name = element.attribute(forName: "name")?.stringValue,
                        let DocumentationTextNode = try? DocumentationTextNode(parsing: element.children ?? []) {
                        params[name] = DocumentationTextNode
                    }
                default: break
            }
        }
    }
}
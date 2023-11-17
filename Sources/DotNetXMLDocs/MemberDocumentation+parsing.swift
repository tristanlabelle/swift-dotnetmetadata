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
                            let content = try? DocumentationTextNode(parsing: element.children ?? []) {
                        typeParams.append(.init(name: name, description: content))
                    }
                case "param":
                    if let name = element.attribute(forName: "name")?.stringValue,
                            let content = try? DocumentationTextNode(parsing: element.children ?? []) {
                        params.append(.init(name: name, description: content))
                    }
                case "exception":
                    if let crefString = element.attribute(forName: "cref")?.stringValue,
                            let cref = try? MemberDocumentationKey(parsing: crefString),
                            let content = try? DocumentationTextNode(parsing: element.children ?? []) {
                        exceptions.append(.init(type: cref, description: content))
                    }
                default: break
            }
        }
    }
}
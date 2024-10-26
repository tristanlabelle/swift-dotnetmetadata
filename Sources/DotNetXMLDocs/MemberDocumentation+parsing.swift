import FoundationXML

extension MemberDocumentation {
    internal init(parsing element: XMLElement) {
        for child in element.children ?? [] {
            guard let element = child as? XMLElement else { continue }

            switch element.name {
                case "summary": summary = parseContentText(element)
                case "remarks": remarks = parseContentText(element)
                case "value": value = parseContentText(element)
                case "returns": returns = parseContentText(element)
                case "typeparam":
                    if let name = element.attribute(forName: "name")?.stringValue,
                            let content = parseContentText(element) {
                        typeParams.append(.init(name: name, description: content))
                    }
                case "param":
                    if let name = element.attribute(forName: "name")?.stringValue,
                            let content = parseContentText(element) {
                        params.append(.init(name: name, description: content))
                    }
                case "exception":
                    if let crefString = element.attribute(forName: "cref")?.stringValue,
                            let cref = try? MemberDocumentationKey(parsing: crefString),
                            case .type(let type) = cref,
                            let content = parseContentText(element) {
                        exceptions.append(.init(type: type, description: content))
                    }
                default: break
            }
        }
    }

    fileprivate func parseContentText(_ element: XMLElement) -> DocumentationText? {
        guard let children = element.children else { return nil }
        if children.count == 1, let child = children.first, child.kind == .text,
                let text = child.stringValue, !text.contains(where: { !$0.isWhitespace }) {
            // All whitespace content, ignore
            return nil
        }
        return try? DocumentationText(parsing: children)
    }
}
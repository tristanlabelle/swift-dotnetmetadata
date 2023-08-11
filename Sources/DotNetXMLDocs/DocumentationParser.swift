import FoundationXML

enum DocumentationParser {
    public static func feed<Sink: DocumentationSink>(document: XMLDocument, sink: inout Sink) {
        if let root = document.rootElement(), root.name == "doc" {
            if let assembly = root.singleElement(forName: "assembly") {
                if let name = assembly.singleElement(forName: "name")?.stringValue {
                    sink.setAssembly(name: name)
                }
            }

            if let members = root.singleElement(forName: "members") {
                for member in members.elements(forName: "member") {
                    if let memberName = member.attribute(forName: "name")?.stringValue,
                        let memberKey = try? MemberKey(parsing: memberName) {

                        let entry = parseMemberEntry(member)
                        sink.addMember(key: key, entry: entry)
                    }
                }
            }
        }
    }

    fileprivate static func parseMemberEntry(_ member: XMLElement) -> MemberEntry {
        var entry = MemberEntry()

        for child in member.children ?? [] {
            if let element = child as? XMLElement {
                switch element.name {
                case "summary": entry.summary = parseTextNode(element.children ?? [])
                case "remarks": entry.remarks = parseTextNode(element.children ?? [])
                case "value": entry.value = parseTextNode(element.children ?? [])
                case "returns": entry.returns = parseTextNode(element.children ?? [])
                case "typeparam":
                    if let name = element.attribute(forName: "name")?.stringValue {
                        entry.typeParams[name] = parseTextNode(element.children ?? [])
                    }
                case "param":
                    if let name = element.attribute(forName: "name")?.stringValue {
                        entry.params[name] = parseTextNode(element.children ?? [])
                    }
                default:
                    break
                }
            }
        }

        return entry
    }

    fileprivate static func parseTextNode(_ nodes: [XMLNode]) -> TextNode {
        return nodes.count == 1 ? parseTextNode(nodes[0]) : .sequence(nodes.map(parseTextNode))
    }

    fileprivate static func parseTextNode(_ node: XMLNode) -> TextNode {
        if node.kind == .text {
            return .string(node.stringValue ?? "")
        }
        else {
            return .sequence(node.children?.map(parseTextNode) ?? [])
        }
    }
}

extension XMLElement {
    fileprivate func firstElement(forName name: String) -> XMLElement? {
        let elements = self.elements(forName: name)
        return elements.count > 0 ? elements[0] : nil
    }

    fileprivate func singleElement(forName name: String) -> XMLElement? {
        let elements = self.elements(forName: name)
        return elements.count == 1 ? elements[0] : nil
    }
}
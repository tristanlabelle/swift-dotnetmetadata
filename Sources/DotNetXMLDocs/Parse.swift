import FoundationXML

public func parse<Sink: DocumentationSink>(document: XMLDocument, to sink: inout Sink) {
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
                    let entry = MemberEntry(parsing: member)
                    sink.addMember(key: memberKey, entry: entry)
                }
            }
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
import FoundationXML

extension AssemblyDocumentation {
    public static func parse<Sink: AssemblyDocumentationSink>(document: XMLDocument, to sink: inout Sink) {
        if let root = document.rootElement(), root.name == "doc" {
            if let assembly = root.singleElement(forName: "assembly") {
                if let name = assembly.singleElement(forName: "name")?.stringValue {
                    sink.setAssemblyName(name)
                }
            }

            if let members = root.singleElement(forName: "members") {
                for member in members.elements(forName: "member") {
                    if let memberName = member.attribute(forName: "name")?.stringValue,
                        let memberDocKey = try? MemberDocumentationKey(parsing: memberName) {
                        let memberDoc = MemberDocumentation(parsing: member)
                        sink.addMember(memberDoc, forKey: memberDocKey)
                    }
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

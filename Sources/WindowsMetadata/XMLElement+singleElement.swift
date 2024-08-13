import FoundationXML

extension XMLElement {
    internal func singleElement(forName name: String) -> XMLElement? {
        let elements = self.elements(forName: name)
        return elements.count == 1 ? elements[0] : nil
    }
}

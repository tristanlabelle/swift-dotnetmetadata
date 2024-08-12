import DotNetMetadata
import struct Foundation.URL
import FoundationXML

extension WindowsSDK {
    // From Platform.xml or PreviousPlatforms.xml
    public struct ApplicationPlatform {
        public var name: String
        public var friendlyName: String
        public var version: FourPartVersion
        public var apiContracts: [String: FourPartVersion]

        public init(readingFileAtPath filePath: String) throws {
            let url = URL(fileURLWithPath: filePath)
            let document = try XMLDocument(contentsOf: url, options: [])
            try self.init(parsing: document)
        }

        public init(parsing document: XMLDocument) throws {
            guard let rootElement = document.rootElement(), rootElement.name == "ApplicationPlatform" else {
                fatalError()
            }
            self.name = rootElement.attribute(forName: "name")!.stringValue!
            self.friendlyName = rootElement.attribute(forName: "friendlyName")!.stringValue!
            self.version = try FourPartVersion(parsing: rootElement.attribute(forName: "version")!.stringValue!)
            self.apiContracts = [:]
            for apiContractElement in rootElement.singleElement(forName: "ContainedApiContracts")!.elements(forName: "ApiContract") {
                let name = apiContractElement.attribute(forName: "name")!.stringValue!
                let version = try FourPartVersion(parsing: apiContractElement.attribute(forName: "version")!.stringValue!)
                self.apiContracts[name] = version
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

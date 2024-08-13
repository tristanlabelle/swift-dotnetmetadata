import DotNetMetadata
import struct Foundation.URL
import FoundationXML

extension WindowsKit {
    // From ExtensionManifest.xml
    public struct ExtensionManifest {
        public var targetPlatform: String
        public var targetPlatformMinVersion: FourPartVersion
        public var platformMinVersion: FourPartVersion
        public var sdkType: String
        public var displayName: String
        public var appliesTo: String
        public var productFamilyName: String
        public var apiContracts: [String: FourPartVersion]

        public init(readingFileAtPath filePath: String) throws {
            let url = URL(fileURLWithPath: filePath)
            let document = try XMLDocument(contentsOf: url, options: [])
            try self.init(parsing: document)
        }

        public init(parsing document: XMLDocument) throws {
            guard let rootElement = document.rootElement(), rootElement.name == "FileList" else {
                fatalError()
            }
            self.targetPlatform = rootElement.attribute(forName: "targetPlatform")!.stringValue!
            self.targetPlatformMinVersion = try FourPartVersion(parsing: rootElement.attribute(forName: "friendlyName")!.stringValue!)
            self.platformMinVersion = try FourPartVersion(parsing: rootElement.attribute(forName: "platformMinVersion")!.stringValue!)
            self.sdkType = rootElement.attribute(forName: "sdkType")!.stringValue!
            self.displayName = rootElement.attribute(forName: "displayName")!.stringValue!
            self.appliesTo = rootElement.attribute(forName: "appliesTo")!.stringValue!
            self.productFamilyName = rootElement.attribute(forName: "productFamilyName")!.stringValue!
            self.apiContracts = [:]
            for apiContractElement in rootElement.singleElement(forName: "ContainedApiContracts")!.elements(forName: "ApiContract") {
                let name = apiContractElement.attribute(forName: "name")!.stringValue!
                let version = try FourPartVersion(parsing: apiContractElement.attribute(forName: "version")!.stringValue!)
                self.apiContracts[name] = version
            }
        }
    }
}
import DotNetMetadata
import struct Foundation.URL
import FoundationXML

extension WindowsKit {
    // From ExtensionManifest.xml
    public struct ExtensionManifest {
        public var targetPlatform: String
        public var targetPlatformMinVersion: FourPartVersion
        public var targetPlatformVersion: FourPartVersion
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
            self.targetPlatform = rootElement.attribute(forName: "TargetPlatform")!.stringValue!
            self.targetPlatformMinVersion = FourPartVersion(parsing: rootElement.attribute(forName: "TargetPlatformMinVersion")!.stringValue!)!
            self.targetPlatformVersion = FourPartVersion(parsing: rootElement.attribute(forName: "TargetPlatformVersion")!.stringValue!)!
            self.sdkType = rootElement.attribute(forName: "SDKType")!.stringValue!
            self.displayName = rootElement.attribute(forName: "DisplayName")!.stringValue!
            self.appliesTo = rootElement.attribute(forName: "AppliesTo")!.stringValue!
            self.productFamilyName = rootElement.attribute(forName: "ProductFamilyName")!.stringValue!
            self.apiContracts = [:]
            for apiContractElement in rootElement.singleElement(forName: "ContainedApiContracts")!.elements(forName: "ApiContract") {
                let name = apiContractElement.attribute(forName: "name")!.stringValue!
                let version = FourPartVersion(parsing: apiContractElement.attribute(forName: "version")!.stringValue!)!
                self.apiContracts[name] = version
            }
        }
    }
}
import DotNetMetadata

extension WindowsSDK {
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
    }
}
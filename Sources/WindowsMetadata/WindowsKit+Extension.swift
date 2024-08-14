extension WindowsKit {
    public final class Extension {
        private unowned let kit: WindowsKit!
        public let name: String

        internal init(kit: WindowsKit, name: String) {
            self.kit = kit
            self.name = name
        }

        public var manifestXMLPath: String {
            "\(kit.rootDirectory)\\Extension SDKs\\\(name)\\\(kit.version)\\SDKManifest.xml"
        }

        public func readManifest() throws -> ExtensionManifest {
            try ExtensionManifest(readingFileAtPath: manifestXMLPath)
        }
    }
}
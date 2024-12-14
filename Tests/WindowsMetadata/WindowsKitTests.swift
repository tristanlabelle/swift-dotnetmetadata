@testable import WindowsMetadata
import Testing

struct WindowsKitTests {
    @Test func testReadApplicationPlatformXml() throws {
        let kits = try WindowsKit.getInstalled()
        try XCTSkipIf(kits.isEmpty, "No Windows Kits found")

        let applicationPlatform = try kits[0].readApplicationPlatform()
        #expect(applicationPlatform.apiContracts["Windows.Foundation.UniversalApiContract"] != nil)
    }

    @Test func testReadExtensionManifestXml() throws {
        let kits = try WindowsKit.getInstalled()
        try XCTSkipIf(kits.isEmpty, "No Windows Kits found")

        let desktopExtension = try #require(kits[0].extensions.first { $0.name == "WindowsDesktop" })
        let manifest = try desktopExtension.readManifest()
        #expect(manifest.productFamilyName == "Windows.Desktop")
    }
}
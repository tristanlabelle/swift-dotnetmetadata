import DotNetMetadata
import class Foundation.Bundle
import struct Foundation.UUID
import Testing
import WindowsMetadata

struct InterfaceIDTests {
    private var context: WinMDLoadContext
    private var mscorlib: Assembly

    init() throws {
        context = WinMDLoadContext()

        // Expect mscorlib.winmd side-by-side with the test executable
        let mscorlibURL = Bundle.main.bundleURL.appendingPathComponent("mscorlib.winmd", isDirectory: false)
        mscorlib = try context.load(url: mscorlibURL)
    }

    /// Test that we can get the interface ID for `IActivationFactory`,
    /// which lives in the core library rather than a Windows Metadata file,
    /// so uses System's GuidAttribute, not Windows.Foundation's.
    @Test func testCoreLibraryIActivationFactory() throws {
        let typeDefinition = try #require(try mscorlib.resolveTypeDefinition(
            namespace: "System.Runtime.InteropServices.WindowsRuntime", name: "IActivationFactory"))
        #expect(try getInterfaceID(typeDefinition) == UUID(uuidString: "00000035-0000-0000-c000-000000000046"))
    }
}
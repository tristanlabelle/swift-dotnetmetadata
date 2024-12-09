import DotNetMetadata
import XCTest
import WindowsMetadata

final class InterfaceIDTests: XCTestCase {
    internal static var context: WinMDLoadContext!
    internal static var mscorlib: Assembly!

    override func setUpWithError() throws {
        if Self.mscorlib == nil {
            Self.context = WinMDLoadContext()

            // Expect mscorlib.winmd side-by-side with the test executable
            let mscorlibURL = Bundle.main.bundleURL.appendingPathComponent("mscorlib.winmd", isDirectory: false)
            Self.mscorlib = try Self.context.load(url: mscorlibURL)
        }
    }

    /// Test that we can get the interface ID for `IActivationFactory`,
    /// which lives in the core library rather than a Windows Metadata file,
    /// so uses System's GuidAttribute, not Windows.Foundation's.
    public func testCoreLibraryIActivationFactory() throws {
        let typeDefinition = try XCTUnwrap(Self.mscorlib.resolveTypeDefinition(
            namespace: "System.Runtime.InteropServices.WindowsRuntime", name: "IActivationFactory"))
        XCTAssertEqual(
            try getInterfaceID(typeDefinition),
            UUID(uuidString: "00000035-0000-0000-c000-000000000046"))
    }
}
@testable import DotNetMetadata
import DotNetMetadataFormat
import XCTest

final class WinMetadataTests: XCTestCase {
    internal static var context: AssemblyLoadContext!
    internal static var assembly: Assembly!

    override class func setUp() {
        guard let windowsFoundationPath = SystemAssemblies.WinMetadata.windowsFoundationPath else { return }
        let url = URL(fileURLWithPath: windowsFoundationPath)

        // Resolve the mscorlib dependency from the .NET Framework 4 machine installation
        context = AssemblyLoadContext(resolver: {
            guard $0.name == Mscorlib.name, let mscorlibPath = SystemAssemblies.DotNetFramework4.mscorlibPath else { throw AssemblyLoadError.notFound() }
            return try ModuleFile(path: mscorlibPath)
        })

        assembly = try? context.load(url: url)
    }

    override func setUpWithError() throws {
        try XCTSkipIf(Self.assembly == nil, "System Windows.Foundation.winmd not found")
    }

    func testMscorlibTypeReference() throws {
        XCTAssertEqual(
            try Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point")?.base?.definition.fullName,
            "System.ValueType")
    }
}

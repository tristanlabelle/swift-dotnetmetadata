@testable import DotNetMetadata
import DotNetMetadataFormat
import XCTest

final class WinMetadataTests: XCTestCase {
    internal static var context: MetadataContext!
    internal static var assembly: Assembly!

    override class func setUp() {
        guard let winMetadataPath = SystemAssemblyPaths.winMetadata else { return }
        let url = URL(fileURLWithPath: "\(winMetadataPath)\\Windows.Foundation.winmd")

        // Resolve the mscorlib dependency from the .NET Framework 4 machine installation
        struct AssemblyLoadError: Error {}
        context = MetadataContext(assemblyResolver: {
            guard $0.name == "mscorlib", let fx4Path = SystemAssemblyPaths.framework4 else { throw AssemblyLoadError() }
            return try ModuleFile(path: "\(fx4Path)\\mscorlib.dll")
        })

        assembly = try? context.loadAssembly(url: url)
    }

    override func setUpWithError() throws {
        try XCTSkipIf(Self.assembly == nil, "System Windows.Foundation.winmd not found")
    }

    func testMscorlibTypeReference() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point")?.base?.definition.fullName,
            "System.ValueType")
    }
}

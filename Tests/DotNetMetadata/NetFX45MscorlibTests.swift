@testable import DotNetMetadata
import Testing

struct NetFX45MscorlibTests {
    private var context: AssemblyLoadContext
    private var assembly: Assembly
    private var coreLibrary: CoreLibrary { get throws { try context.coreLibrary } }

    init() throws {
        guard let mscorlibPath = SystemAssemblies.DotNetFramework4.mscorlibPath else { return }

        context = AssemblyLoadContext()
        assembly = try context.load(path: mscorlibPath)
    }

    @Test func testTypeLookup() throws {
        #expect(try assembly.resolveTypeDefinition(fullName: "System.Object") != nil)
    }
}

@testable import DotNetMetadata
import XCTest

internal final class StructLayoutTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        using System.Runtime.InteropServices;

        [StructLayout(LayoutKind.Auto)]
        struct Auto {}

        [StructLayout(LayoutKind.Sequential, Pack = 2, Size = 24)]
        struct Sequential {}

        [StructLayout(LayoutKind.Explicit, Size = 24)]
        struct Explicit {
            [FieldOffset(16)]
            int A;
            [FieldOffset(16)]
            float B;
        }
        """
    }

    public func testAuto() throws {
        let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Auto"))
        XCTAssertEqual(typeDefinition.layout, .auto)
    }

    public func testSequential() throws {
        let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Sequential"))
        XCTAssertEqual(typeDefinition.layout, .sequential(pack: 2, minSize: 24))
    }

    public func testExplicit() throws {
        let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Explicit"))
        XCTAssertEqual(typeDefinition.layout, .explicit(minSize: 24))
    }

    public func testFieldOffset() throws {
        let typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Explicit"))
        XCTAssertEqual(typeDefinition.findField(name: "A")?.explicitOffset, 16)
        XCTAssertEqual(typeDefinition.findField(name: "B")?.explicitOffset, 16)
    }
}
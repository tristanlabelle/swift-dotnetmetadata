@testable import DotNetMetadata
import WindowsMetadata
import DotNetMetadataFormat
import struct Foundation.UUID
import class Foundation.Bundle
import Testing

struct WinMetadataTests {
    private var context: AssemblyLoadContext
    private var mscorlib: Assembly
    private var assembly: Assembly

    init() throws {
        context = WinMDLoadContext()

        // Expect mscorlib.winmd side-by-side with the test executable
        let mscorlibURL = Bundle.main.bundleURL.appendingPathComponent("mscorlib.winmd", isDirectory: false)
        mscorlib = try context.load(url: mscorlibURL)

        guard let windowsFoundationPath = SystemAssemblies.WinMetadata.windowsFoundationPath else {
            try XCTSkipIf(true, "System Windows.Foundation.winmd not found")
            return
        }

        assembly = try context.load(url: URL(fileURLWithPath: windowsFoundationPath))
    }

    @Test func testMscorlibTypeReference() throws {
        let pointTypeDefinition = try #require(assembly.resolveTypeDefinition(fullName: "Windows.Foundation.Point"))
        #expect(try #require(pointTypeDefinition.base).definition.fullName == "System.ValueType")
    }

    @Test func testParameterizedInterfaceID() throws {
        let iasyncOperation = try #require(assembly.resolveTypeDefinition(fullName: "Windows.Foundation.IAsyncOperation`1") as? InterfaceDefinition)
        #expect(
            try WindowsMetadata.getInterfaceID(iasyncOperation, genericArgs: [try Self.context.coreLibrary.systemBoolean.bindNode()])
            == UUID(uuidString: "cdb5efb3-5788-509d-9be1-71ccb8a3362a"))
    }

    @Test func testWinRTTypeNameFromType() throws {
        let imemoryReference = try #require(assembly.resolveTypeDefinition(fullName: "Windows.Foundation.IMemoryBufferReference") as? InterfaceDefinition)
        let closedEvent = try #require(imemoryReference.findEvent(name: "Closed"))
        let typeName = try WinRTTypeName.from(type: closedEvent.handlerType.asBoundType)
        #expect(typeName.description == "Windows.Foundation.TypedEventHandler<Windows.Foundation.IMemoryBufferReference, Object>")
    }
}

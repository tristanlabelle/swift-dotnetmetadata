@testable import DotNetMetadata
import WindowsMetadata
import DotNetMetadataFormat
import struct Foundation.UUID
import class Foundation.Bundle
import XCTest

final class WinMetadataTests: XCTestCase {
    internal static var setUpError: Error?
    internal static var context: AssemblyLoadContext!
    internal static var mscorlib: Assembly!
    internal static var assembly: Assembly!

    override class func setUp() {
        do {
            context = WinMDLoadContext()

            // Expect mscorlib.winmd side-by-side with the test executable
            let mscorlibURL = Bundle.main.bundleURL.appendingPathComponent("mscorlib.winmd", isDirectory: false)
            mscorlib = try context.load(url: mscorlibURL)

            guard let windowsFoundationPath = SystemAssemblies.WinMetadata.windowsFoundationPath else {
                try XCTSkipIf(true, "System Windows.Foundation.winmd not found")
                return
            }

            assembly = try context.load(url: URL(fileURLWithPath: windowsFoundationPath))
        } catch {
            setUpError = error
            XCTFail("Failed to set up test: \(error)")
        }
    }

    override func setUpWithError() throws {
        if let error = Self.setUpError {
            throw error
        }
    }

    override class func tearDown() {
        assembly = nil
        mscorlib = nil
        context = nil
        setUpError = nil
    }

    func testMscorlibTypeReference() throws {
        let pointTypeDefinition = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "Windows.Foundation.Point"))
        XCTAssertEqual(
            try XCTUnwrap(pointTypeDefinition.base).definition.fullName,
            "System.ValueType")
    }

    func testParameterizedInterfaceID() throws {
        let iasyncOperation = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "Windows.Foundation.IAsyncOperation`1") as? InterfaceDefinition)
        XCTAssertEqual(
            try WindowsMetadata.getInterfaceID(iasyncOperation, genericArgs: [try Self.context.coreLibrary.systemBoolean.bindNode()]),
            UUID(uuidString: "cdb5efb3-5788-509d-9be1-71ccb8a3362a"))
    }

    func testWinRTTypeNameFromType() throws {
        let imemoryReference = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "Windows.Foundation.IMemoryBufferReference") as? InterfaceDefinition)
        let closedEvent = try XCTUnwrap(imemoryReference.findEvent(name: "Closed"))
        let typeName = try WinRTTypeName.from(type: closedEvent.handlerType.asBoundType)
        XCTAssertEqual(typeName.description, "Windows.Foundation.TypedEventHandler<Windows.Foundation.IMemoryBufferReference, Object>")
    }
}

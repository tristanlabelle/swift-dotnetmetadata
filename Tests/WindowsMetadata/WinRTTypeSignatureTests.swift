import Testing
import WindowsMetadata

struct WinRTTypeSignatureTests {
    @Test func testInterfaceID() throws {
        let ireferenceInterfaceID = UUID(uuidString: "61c17706-2d65-11e0-9ae8-d48564015472")!
        let signature: WinRTTypeSignature = .interface(id: ireferenceInterfaceID, args: [.baseType(.int32)])
        #expect(signature.parameterizedID == UUID(uuidString: "548cefbd-bc8a-5fa0-8df2-957440fc8bf4")) // IReference<Int32>
    }
}
import Testing
import WindowsMetadata

struct MidlNameManglingTests {
    @Test func testObject() throws {
        #expect(MidlNameMangling.get(.object) == "IInspectable")
    }

    @Test func testWinRTType() throws {
        let typeName: WinRTTypeName = .declared(namespace: "Windows.Foundation", name: "Uri")
        #expect(MidlNameMangling.get(typeName) == "__x_ABI_CWindows_CFoundation_CUri")
    }

    @Test func testGenericOfWinRTType() throws {
        let typeName: WinRTTypeName = .parameterized(.collections_ivector,
            args: [ .declared(namespace: "Windows.Foundation", name: "Uri") ])
        #expect(MidlNameMangling.get(typeName) == "__FIVector_1_Windows__CFoundation__CUri")
    }

    @Test func testGenericOfPrimitiveType() throws {
        let typeName: WinRTTypeName = .parameterized(.collections_ivector,
            args: [ .primitive(.string) ])
        #expect(MidlNameMangling.get(typeName) == "__FIVector_1_HSTRING")
    }

    @Test func testGenericWithTwoArgs() throws {
        let typeName: WinRTTypeName = .parameterized(.collections_imap,
            args: [ .primitive(.string), .primitive(.string) ])
        #expect(MidlNameMangling.get(typeName) == "__FIMap_2_HSTRING_HSTRING")
    }

    @Test func testNestedGenerics() throws {
        let typeName: WinRTTypeName = .parameterized(.iasyncOperation,
            args: [ .parameterized(.collections_ivectorView, args: [ .primitive(.string) ]) ])
        #expect(MidlNameMangling.get(typeName) == "__FIAsyncOperation_1___FIVectorView_1_HSTRING")
    }

    @Test func testGenericDelegates() throws {
        // Should add an I prefix
        let asyncOperationCompletedHandlerOfString = WinRTTypeName.parameterized(.asyncOperationCompletedHandler, args: [ .primitive(.string) ])
        #expect(MidlNameMangling.get(asyncOperationCompletedHandlerOfString) == "__FIAsyncOperationCompletedHandler_1_HSTRING")

        // Except for the collections changed event handlers
        let vectorOfString = WinRTTypeName.parameterized(.collections_ivector, args: [ .primitive(.string) ])
        #expect(MidlNameMangling.get(vectorOfString) == "__FVectorChangedEventHandler_1_HSTRING")
    }
}
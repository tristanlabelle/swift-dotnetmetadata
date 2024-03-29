import XCTest
import WindowsMetadata

final class MidlNameManglingTests: XCTestCase {
    func testObject() throws {
        XCTAssertEqual(MidlNameMangling.get(.object), "IInspectable")
    }

    func testWinRTType() throws {
        let typeName: WinRTTypeName = .declared(namespace: "Windows.Foundation", name: "Uri")
        XCTAssertEqual(MidlNameMangling.get(typeName), "__x_ABI_CWindows_CFoundation_CUri")
    }

    func testGenericOfWinRTType() throws {
        let typeName: WinRTTypeName = .parameterized(.collections_ivector,
            args: [ .declared(namespace: "Windows.Foundation", name: "Uri") ])
        XCTAssertEqual(MidlNameMangling.get(typeName), "__FIVector_1_Windows__CFoundation__CUri")
    }

    func testGenericOfPrimitiveType() throws {
        let typeName: WinRTTypeName = .parameterized(.collections_ivector,
            args: [ .primitive(.string) ])
        XCTAssertEqual(MidlNameMangling.get(typeName), "__FIVector_1_HSTRING")
    }

    func testGenericWithTwoArgs() throws {
        let typeName: WinRTTypeName = .parameterized(.collections_imap,
            args: [ .primitive(.string), .primitive(.string) ])
        XCTAssertEqual(MidlNameMangling.get(typeName), "__FIMap_2_HSTRING_HSTRING")
    }

    func testNestedGenerics() throws {
        let typeName: WinRTTypeName = .parameterized(.iasyncOperation,
            args: [ .parameterized(.collections_ivectorView, args: [ .primitive(.string) ]) ])
        XCTAssertEqual(MidlNameMangling.get(typeName), "__FIAsyncOperation_1___FIVectorView_1_HSTRING")
    }

    func testGenericDelegates() throws {
        // Should add an I prefix
        XCTAssertEqual(
            MidlNameMangling.get(WinRTTypeName.parameterized(.asyncOperationCompletedHandler, args: [ .primitive(.string) ])),
            "__FIAsyncOperationCompletedHandler_1_HSTRING")

        // Except for the collections changed event handlers
        XCTAssertEqual(
            MidlNameMangling.get(WinRTTypeName.parameterized(.collections_vectorChangedEventHandler, args: [ .primitive(.string) ])),
            "__FVectorChangedEventHandler_1_HSTRING")
    }
}
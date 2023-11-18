import XCTest
import WindowsMetadata

final class WinRTTypeNameTests: XCTestCase {
    func testMidlManglingOfWinRTType() throws {
        let typeName: WinRTTypeName = .declared(namespace: "Windows.Foundation", name: "Uri")
        XCTAssertEqual(typeName.midlMangling, "__x_ABI_CWindows_CFoundation_CUri")
    }

    func testMidlManglingOfGenericOfWinRTType() throws {
        let typeName: WinRTTypeName = .parameterized(.collections_ivector,
            args: [ .declared(namespace: "Windows.Foundation", name: "Uri") ])
        XCTAssertEqual(typeName.midlMangling, "__FIVector_1_Windows__CFoundation__CUri")
    }

    func testMidlManglingOfGenericOfPrimitiveType() throws {
        let typeName: WinRTTypeName = .parameterized(.collections_ivector,
            args: [ .primitive(.string) ])
        XCTAssertEqual(typeName.midlMangling, "__FIVector_1_HSTRING")
    }

    func testMidlManglingOfGenericWithTwoArgs() throws {
        let typeName: WinRTTypeName = .parameterized(.collections_imap,
            args: [ .primitive(.string), .primitive(.string) ])
        XCTAssertEqual(typeName.midlMangling, "__FIMap_2_HSTRING_HSTRING")
    }

    func testMidlManglingOfNestedGenerics() throws {
        let typeName: WinRTTypeName = .parameterized(.iasyncOperation,
            args: [ .parameterized(.collections_ivectorView, args: [ .primitive(.string) ]) ])
        XCTAssertEqual(typeName.midlMangling, "__FIAsyncOperation_1___FIVectorView_1_HSTRING")
    }

    func testMidlManglingOfGenericDelegates() throws {
        // Should add an I prefix
        XCTAssertEqual(
            WinRTTypeName.parameterized(.asyncOperationCompletedHandler, args: [ .primitive(.string) ]).midlMangling,
            "__FIAsyncOperationCompletedHandler_1_HSTRING")

        // Except for the collections changed event handlers
        XCTAssertEqual(
            WinRTTypeName.parameterized(.collections_vectorChangedEventHandler, args: [ .primitive(.string) ]).midlMangling,
            "__FVectorChangedEventHandler_1_HSTRING")
    }
}
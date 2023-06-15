import Foundation
import XCTest
@testable import DotNetMD

extension WindowsWinMDTests {
    func testArrayType() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IPropertyValue")?
                .findSingleMethod(name: "GetDoubleArray")?.params[0].type,
            BoundType.array(element: Self.context.mscorlib!.specialTypes.double.bindNonGeneric()))
    }

    func testGenericArgType() throws {
        guard let iasyncOperation = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncOperation`1") else {
            XCTFail("Couldn't find IAsyncOperation`1")
            return
        }

        XCTAssertEqual(
            iasyncOperation.findSingleMethod(name: "GetResults")?.returnType,
            BoundType.genericArg(param: iasyncOperation.genericParams[0]))
    }

    func testGenericInstType() throws {
        guard let iasyncOperation = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncOperation`1") else {
            XCTFail("Couldn't find IAsyncOperation`1")
            return
        }

        guard let iasyncOperationCompletedHandler = Self.assembly.findDefinedType(fullName: "Windows.Foundation.AsyncOperationCompletedHandler`1") else {
            XCTFail("Couldn't find AsyncOperationCompletedHandler`1")
            return
        }

        XCTAssertEqual(
            iasyncOperation.findProperty(name: "Completed")?.type,
            iasyncOperationCompletedHandler.bind(genericArgs: [
                BoundType.genericArg(param: iasyncOperation.genericParams[0])
            ]))
    }
}

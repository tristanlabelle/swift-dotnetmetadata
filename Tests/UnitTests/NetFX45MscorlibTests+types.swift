import Foundation
import XCTest
@testable import DotNetMD

extension NetFX45MscorlibTests {
    func testArrayType() throws {
        guard let arraySegment = Self.assembly.findDefinedType(fullName: "System.ArraySegment`1") else {
            XCTFail("Couldn't find System.ArraySegment`1")
            return
        }

        try XCTAssertEqual(
            arraySegment.findProperty(name: "Array")?.type,
            BoundType.array(element: .genericArg(param: arraySegment.genericParams[0])))
    }

    func testGenericArgType() throws {
        guard let nullable = Self.assembly.findDefinedType(fullName: "System.Nullable`1") else {
            XCTFail("Couldn't find System.Nullable`1")
            return
        }

        try XCTAssertEqual(
            nullable.findProperty(name: "Value")?.type,
            BoundType.genericArg(param: nullable.genericParams[0]))
    }

    func testGenericInstType() throws {
        guard let ienumerable = Self.assembly.findDefinedType(fullName: "System.Collections.Generic.IEnumerable`1") else {
            XCTFail("Couldn't find System.Collections.Generic.IEnumerable`1")
            return
        }

        guard let ienumerator = Self.assembly.findDefinedType(fullName: "System.Collections.Generic.IEnumerator`1") else {
            XCTFail("Couldn't find AsyncOperationCompletedHandler`1")
            return
        }

        try XCTAssertEqual(
            ienumerable.findSingleMethod(name: "GetEnumerator")?.returnType,
            ienumerator.bind(genericArgs: [ BoundType.genericArg(param: ienumerable.genericParams[0]) ]))
    }
}

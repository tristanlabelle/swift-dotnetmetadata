import Foundation
import XCTest
@testable import DotNetMD

extension NetFX45MscorlibTests {
    func testArrayType() throws {
        guard let arraySegment = Self.assembly.findDefinedType(fullName: "System.ArraySegment`1") else {
            return XCTFail("Couldn't find System.ArraySegment`1")
        }

        try XCTAssertEqual(
            arraySegment.findProperty(name: "Array")?.type,
            TypeNode.array(element: .genericArg(param: arraySegment.genericParams[0])))
    }

    func testGenericArgType() throws {
        guard let nullable = Self.assembly.findDefinedType(fullName: "System.Nullable`1") else {
            return XCTFail("Couldn't find System.Nullable`1")
        }

        try XCTAssertEqual(
            nullable.findProperty(name: "Value")?.type,
            TypeNode.genericArg(param: nullable.genericParams[0]))
    }

    func testGenericInstType() throws {
        guard let ienumerable = Self.assembly.findDefinedType(fullName: "System.Collections.Generic.IEnumerable`1") else {
            return XCTFail("Couldn't find System.Collections.Generic.IEnumerable`1")
        }

        guard let ienumerator = Self.assembly.findDefinedType(fullName: "System.Collections.Generic.IEnumerator`1") else {
            return XCTFail("Couldn't find AsyncOperationCompletedHandler`1")
        }

        try XCTAssertEqual(
            ienumerable.findSingleMethod(name: "GetEnumerator")?.returnType,
            ienumerator.bindNode(fullGenericArgs: [ TypeNode.genericArg(param: ienumerable.genericParams[0]) ]))
    }
}

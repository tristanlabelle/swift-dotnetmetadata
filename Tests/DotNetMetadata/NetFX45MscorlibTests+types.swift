import Foundation
import XCTest
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    func testArrayType() throws {
        guard let arraySegment = try Self.assembly.resolveTypeDefinition(fullName: "System.ArraySegment`1") else {
            return XCTFail("Couldn't find System.ArraySegment`1")
        }

        try XCTAssertEqual(
            arraySegment.findProperty(name: "Array")?.type,
            TypeNode.array(of: .genericParam(arraySegment.genericParams[0])))
    }

    func testGenericMethodArgType() throws {
        // T[] System.Array.Empty<T>() -- not overloaded
        let arraySort = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.Array")?.findMethod(name: "Empty"))
        XCTAssertEqual(try arraySort.returnType, .array(of: .genericParam(arraySort.genericParams[0])))
    }

    func testGenericTypeArgType() throws {
        guard let nullable = try Self.assembly.resolveTypeDefinition(fullName: "System.Nullable`1") else {
            return XCTFail("Couldn't find System.Nullable`1")
        }

        try XCTAssertEqual(
            nullable.findProperty(name: "Value")?.type,
            TypeNode.genericParam(nullable.genericParams[0]))
    }

    func testPointerType() throws {
        // void* System.IntPtr.ToPointer()
        let intPtrToPointer = try XCTUnwrap(Self.assembly.resolveTypeDefinition(fullName: "System.IntPtr")?.findMethod(name: "ToPointer"))
        XCTAssertEqual(try intPtrToPointer.returnType, .pointer(to: nil))
    }

    func testGenericInstType() throws {
        guard let ienumerable = try Self.assembly.resolveTypeDefinition(fullName: "System.Collections.Generic.IEnumerable`1") else {
            return XCTFail("Couldn't find System.Collections.Generic.IEnumerable`1")
        }

        guard let ienumerator = try Self.assembly.resolveTypeDefinition(fullName: "System.Collections.Generic.IEnumerator`1") else {
            return XCTFail("Couldn't find AsyncOperationCompletedHandler`1")
        }

        try XCTAssertEqual(
            ienumerable.findMethod(name: "GetEnumerator")?.returnType,
            ienumerator.bindNode(genericArgs: [ TypeNode.genericParam(ienumerable.genericParams[0]) ]))
    }
}

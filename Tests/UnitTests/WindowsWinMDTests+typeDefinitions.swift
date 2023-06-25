import Foundation
import XCTest
@testable import DotNetMD

extension WindowsWinMDTests {
    func testTypeName() throws {
        let iclosable = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IClosable")
        XCTAssertEqual(iclosable?.name, "IClosable")
        XCTAssertEqual(iclosable?.namespace, "Windows.Foundation")
        XCTAssertEqual(iclosable?.fullName, "Windows.Foundation.IClosable")
    }

    func testBaseType() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.UI.Xaml.UIElement")?.unboundBase?.fullName,
            "Windows.UI.Xaml.DependencyObject")
    }

    func testBaseInterfaces() throws {
        guard let iasyncInfo = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncAction") else {
            XCTFail("IAsyncAction not found")
            return
        }
        XCTAssertEqual(
            iasyncInfo.baseInterfaces[0].unboundInterface?.fullName,
            "Windows.Foundation.IAsyncInfo")
    }

    func testTypeVisibility() throws {
        XCTAssertEqual(Self.assembly.findDefinedType(fullName: "Windows.Foundation.IStringable")?.visibility, .public)
        XCTAssertEqual(Self.assembly.findDefinedType(fullName: "Windows.Foundation.IDeferral")?.visibility, .assembly)
    }

    func testTypeFlags() throws {
        let guidHelper = Self.assembly.findDefinedType(fullName: "Windows.Foundation.GuidHelper")!
        XCTAssert(guidHelper.isAbstract)
        XCTAssert(guidHelper.isSealed)
    }

    func testTypeDefinitionClass() throws {
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point") as? StructDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.IClosable") as? InterfaceDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.MemoryBuffer") as? ClassDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.AsyncStatus") as? EnumDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.AsyncActionCompletedHandler") as? DelegateDefinition)
    }

    func testTypeGenericParamEnumeration() throws {
        // Interface with 1 generic parameter
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncActionWithProgress`1")?.genericParams.map({ $0.name }),
            [ "TProgress" ])

        // Delegate with 2 generic parameters
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.AsyncOperationProgressHandler`2")?.genericParams.map({ $0.name }),
            [ "TResult", "TProgress" ])
    }

    func testEnum() throws {
        guard let asyncStatus = Self.assembly.findDefinedType(fullName: "Windows.Foundation.AsyncStatus") as? EnumDefinition else {
            XCTFail("AsyncStatus not found")
            return
        }

        try XCTAssertIdentical(asyncStatus.underlyingType, Self.context.mscorlib!.specialTypes.int32)

        try XCTAssertEqual(asyncStatus.findField(name: "Started")?.literalValue, Constant.int32(0))
        try XCTAssertEqual(asyncStatus.findField(name: "Completed")?.literalValue, Constant.int32(1))
        try XCTAssertEqual(asyncStatus.findField(name: "Canceled")?.literalValue, Constant.int32(2))
        try XCTAssertEqual(asyncStatus.findField(name: "Error")?.literalValue, Constant.int32(3))
    }
}

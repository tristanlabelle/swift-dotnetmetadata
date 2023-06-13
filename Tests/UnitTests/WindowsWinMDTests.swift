import Foundation
import XCTest
@testable import DotNetMDLogical

final class WindowsWinMDTests: XCTestCase {
    internal static var context: MetadataContext!
    internal static var assembly: Assembly!

    override class func setUp() {
        do {
            struct AssemblyNotFound: Error {}
            context = MetadataContext(assemblyResolver: { _ in throw AssemblyNotFound() })

            let programFilesX86Path = ProcessInfo.processInfo.environment["ProgramFiles(x86)"] ?? #"C:\Program Files (x86)"#
            let unionMetadataPath = "\(programFilesX86Path)\\Windows Kits\\10\\UnionMetadata"
            let windowsSDKVersions = try FileManager.default.contentsOfDirectory(atPath: unionMetadataPath)
            guard let latestWindowsSDKVersion = windowsSDKVersions.filter({ $0.starts(with: "10.0.") }).max() else { return }
            let url = URL(fileURLWithPath: "\(unionMetadataPath)\\\(latestWindowsSDKVersion)\\Windows.winmd")
            
            assembly = try? context.loadAssembly(url: url)
        }
        catch {
            // Return with assembly == nil
        }
    }

    override func setUpWithError() throws {
        try XCTSkipIf(Self.assembly == nil)
    }

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

    func testMethodFlags() throws {
        let iasyncInfo_get_Id = Self.assembly.findDefinedType(fullName: "Windows.Foundation.IAsyncInfo")?
            .findSingleMethod(name: "get_Id")
        XCTAssertEqual(iasyncInfo_get_Id?.isStatic, false)
        XCTAssertEqual(iasyncInfo_get_Id?.isVirtual, true)
        XCTAssertEqual(iasyncInfo_get_Id?.isAbstract, true)
        XCTAssertEqual(iasyncInfo_get_Id?.isSpecialName, true)

        let guidHelper_createNewGuid = Self.assembly.findDefinedType(fullName: "Windows.Foundation.GuidHelper")?
            .findSingleMethod(name: "CreateNewGuid")
        XCTAssertEqual(guidHelper_createNewGuid?.isStatic, true)
        XCTAssertEqual(guidHelper_createNewGuid?.isVirtual, false)
        XCTAssertEqual(guidHelper_createNewGuid?.isAbstract, false)
        XCTAssertEqual(guidHelper_createNewGuid?.isSpecialName, false)
    }

    func testMscorlibTypeReference() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point")?.unboundBase?.fullName,
            "System.ValueType")
    }

    func testTypeDefinitionKind() throws {
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point") as? StructDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.IClosable") as? InterfaceDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.MemoryBuffer") as? ClassDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.AsyncStatus") as? EnumDefinition)
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.AsyncActionCompletedHandler") as? DelegateDefinition)
    }

    func testMethodKind() throws {
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "Windows.Foundation.MemoryBuffer")?
            .findSingleMethod(name: ".ctor") as? Constructor)
    }

    func testMethodParamEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.AsyncActionCompletedHandler")?
                .findSingleMethod(name: "Invoke")?.params.map { $0.name },
            ["asyncInfo", "asyncStatus"])

        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IClosable")?
                .findSingleMethod(name: "Close")?.params.count, 0)
    }
    
    func testMethodReturnType() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IPropertyValue")?
                .findSingleMethod(name: "GetChar16")?.returnType.asUnbound?.fullName,
            "System.Char")

        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.IClosable")?
                .findSingleMethod(name: "Close")?.returnType.asUnbound?.fullName,
            "System.Void")
    }

    func testMethodParamType() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.PropertyValue")?
                .findSingleMethod(name: "CreateUInt16")?.params[0].type.asUnbound?.fullName,
            "System.UInt16")
    }

    func testFieldType() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point")?
                .findField(name: "X")?.type.asUnbound?.fullName,
            "System.Single")
    }
}

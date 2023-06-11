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
        let iclosable = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IClosable")
        XCTAssertEqual(iclosable?.name, "IClosable")
        XCTAssertEqual(iclosable?.namespace, "Windows.Foundation")
        XCTAssertEqual(iclosable?.fullName, "Windows.Foundation.IClosable")
    }

    func testBaseType() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.UI.Xaml.UIElement")?.unboundBase?.fullName,
            "Windows.UI.Xaml.DependencyObject")
    }

    func testBaseInterfaces() throws {
        guard let iasyncInfo = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IAsyncAction") else {
            XCTFail("IAsyncAction not found")
            return
        }
        XCTAssertEqual(
            iasyncInfo.baseInterfaces[0].unboundInterface?.fullName,
            "Windows.Foundation.IAsyncInfo")
    }

    func testTypeVisibility() throws {
        XCTAssertEqual(Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IStringable")?.visibility, .public)
        XCTAssertEqual(Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IDeferral")?.visibility, .assembly)
    }

    func testTypeFlags() throws {
        let guidHelper = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.GuidHelper")!
        XCTAssert(guidHelper.isAbstract)
        XCTAssert(guidHelper.isSealed)
    }

    func testMethodFlags() throws {
        let iasyncInfo_get_Id = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IAsyncInfo")?
            .findSingleMethod(name: "get_Id")
        XCTAssertEqual(iasyncInfo_get_Id?.isStatic, false)
        XCTAssertEqual(iasyncInfo_get_Id?.isVirtual, true)
        XCTAssertEqual(iasyncInfo_get_Id?.isAbstract, true)
        XCTAssertEqual(iasyncInfo_get_Id?.isSpecialName, true)

        let guidHelper_createNewGuid = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.GuidHelper")?
            .findSingleMethod(name: "CreateNewGuid")
        XCTAssertEqual(guidHelper_createNewGuid?.isStatic, true)
        XCTAssertEqual(guidHelper_createNewGuid?.isVirtual, false)
        XCTAssertEqual(guidHelper_createNewGuid?.isAbstract, false)
        XCTAssertEqual(guidHelper_createNewGuid?.isSpecialName, false)
    }

    func testMscorlibTypeReference() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.Point")?.unboundBase?.fullName,
            "System.ValueType")
    }

    func testTypeDefinitionKind() throws {
        XCTAssertNotNil(Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.Point") as? StructDefinition)
        XCTAssertNotNil(Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IClosable") as? InterfaceDefinition)
        XCTAssertNotNil(Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.MemoryBuffer") as? ClassDefinition)
        XCTAssertNotNil(Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.AsyncStatus") as? EnumDefinition)
        XCTAssertNotNil(Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.AsyncActionCompletedHandler") as? DelegateDefinition)
    }

    func testMethodParamEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.AsyncActionCompletedHandler")?
                .findSingleMethod(name: "Invoke")?
                .params.map { $0.name },
            ["asyncInfo", "asyncStatus"])
    }
}

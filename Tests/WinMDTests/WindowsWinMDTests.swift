import Foundation
import XCTest
@testable import WinMDGraph

final class WindowsWinMDTests: XCTestCase {
    private static var context: MetadataContext!
    private static var assembly: Assembly!

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

    func testBaseInterfaces() throws {
        guard let iasyncAction = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IAsyncAction") else {
            XCTFail("IAsyncAction not found")
            return
        }
        guard case .simple(let typeDef) = iasyncAction.baseInterfaces[0].interface else {
            XCTFail("Expected simple type")
            return
        }
        XCTAssertEqual(typeDef.fullName, "Windows.Foundation.IAsyncInfo")
    }

    func testGenericParamEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.Collections.IKeyValuePair`2")?.genericParams.map({ $0.name }).sorted(),
            [ "K", "V" ])
    }

    func testMethodEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IAsyncInfo")?.methods.map({ $0.name }).sorted(),
            [ "Cancel", "Close", "get_ErrorCode", "get_Id", "get_Status" ])
    }

    func testFieldEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.Point")?.fields.map({ $0.name }).sorted(),
            [ "X", "Y" ])
    }

    func testPropertyEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IAsyncInfo")?.properties.map({ $0.name }).sorted(),
            [ "ErrorCode", "Id", "Status" ])
    }

    func testEventEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Devices.Enumeration.DeviceWatcher")?.events.map({ $0.name }).sorted(),
            [ "Added", "EnumerationCompleted", "Removed", "Stopped", "Updated" ])
    }

    func testGenericTypeParamEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.Collections.IMap`2")?.genericParams.map({ $0.name }).sorted(),
            [ "K", "V" ])
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
}

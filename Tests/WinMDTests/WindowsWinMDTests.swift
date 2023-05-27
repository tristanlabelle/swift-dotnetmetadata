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
        let iclosable = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IClosable")!
        XCTAssertEqual(iclosable.name, "IClosable")
        XCTAssertEqual(iclosable.namespace, "Windows.Foundation")
        XCTAssertEqual(iclosable.fullName, "Windows.Foundation.IClosable")
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
        let istringable_toString = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IStringable")?
            .findSingleMethod(name: "ToString")
        XCTAssertEqual(istringable_toString?.isStatic, false)
        XCTAssertEqual(istringable_toString?.isVirtual, true)
        XCTAssertEqual(istringable_toString?.isAbstract, true)

        let guidHelper_createNewGuid = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.GuidHelper")?
            .findSingleMethod(name: "CreateNewGuid")
        XCTAssertEqual(guidHelper_createNewGuid?.isStatic, true)
        XCTAssertEqual(guidHelper_createNewGuid?.isVirtual, false)
        XCTAssertEqual(guidHelper_createNewGuid?.isAbstract, false)
    }
}
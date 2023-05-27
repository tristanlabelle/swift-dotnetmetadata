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
        let iclosable = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.IClosable")!
        let methods = iclosable.methods
        XCTAssertEqual(methods.count, 1)
        XCTAssertEqual(methods[0].name, "Close")
    }

    func testFieldEnumeration() throws {
        let point = Self.assembly.findTypeDefinition(fullName: "Windows.Foundation.Point")!
        let fields = point.fields.sorted { $0.name < $1.name }
        XCTAssertEqual(fields.count, 2)
        XCTAssertEqual(fields[0].name, "X")
        XCTAssertEqual(fields[1].name, "Y")
    }
}

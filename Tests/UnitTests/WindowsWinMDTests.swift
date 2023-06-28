import Foundation
import XCTest
@testable import DotNetMD

final class WindowsWinMDTests: XCTestCase {
    internal static var context: MetadataContext!
    internal static var assembly: Assembly!

    override class func setUp() {
        do {
            context = MetadataContext()

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

    func testMscorlibTypeReference() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point")?.unboundBase?.fullName,
            "System.ValueType")
    }
}

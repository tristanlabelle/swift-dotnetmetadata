import Foundation
import XCTest
@testable import WinMD

final class WinMDTests: XCTestCase {
    func testExample() throws {
        let url = URL(fileURLWithPath: #"C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.22000.0\Windows.winmd"#)
        let database = try Database(url: url)
    }
}

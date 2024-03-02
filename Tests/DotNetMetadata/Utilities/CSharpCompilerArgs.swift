import DotNetMetadata
import Foundation
import WinSDK

internal struct CSharpCompilerArgs {
    enum Target { case library }

    public var nologo: Bool = false
    public var nostdlib: Bool?
    public var optimize: Bool?
    public var debug: Bool?
    public var unsafe: Bool?
    public var target: Target = .library
    public var references: [String] = []
    public var output: String?
    public var sources: [String] = []

    public func buildCommandLineArgs() -> [String] {
        var args = [String]()

        if nologo { args.append("-nologo") }
        if let nostdlib { args.append(nostdlib ? "-nostdlib+" : "-nostdlib-") }
        switch target {
            case .library: args.append("-target:library")
        }
        if let optimize { args.append(optimize ? "-optimize+" : "-optimize-") }
        if let debug { args.append(debug ? "-debug+" : "-debug-") }
        if let unsafe { args.append(unsafe ? "-unsafe+" : "-unsafe-") }
        for reference in references { args.append("-reference:\(reference)") }
        if let output { args.append("-out:\(output)") }
        for source in sources { args.append(source) }

        return args
    }
}
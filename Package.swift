// swift-tools-version: 5.8

import PackageDescription

// Workaround for SPM library support limitations causing "LNK4217: locally defined symbol imported" spew
let executableLinkerSettings = [ LinkerSetting.unsafeFlags(["-Xlinker", "-ignore:4217"]) ]

let package = Package(
    name: "DotNetMetadata",
    products: [
        .library(
            name: "DotNetMetadata",
            targets: [
                "DotNetMetadataFormat",
                "DotNetMetadata",
                "DotNetXMLDocs",
                "DotNetXMLDocsFromMetadata",
                "WindowsMetadata"
            ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", revision: "18c42c19cac3fafd61cab1156d4088664b7424ae"), // 6.0.3
    ],
    targets: [
        .target(
            name: "DotNetMetadataCInterop",
            exclude: ["CMakeLists.txt"]),

        .target(
            name: "DotNetMetadataFormat",
            dependencies: [ "DotNetMetadataCInterop" ],
            exclude: ["CMakeLists.txt"]),
        .testTarget(
            name: "DotNetMetadataFormatTests",
            dependencies: [
                "DotNetMetadataFormat",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/DotNetMetadataFormat",
            linkerSettings: executableLinkerSettings),

        .target(
            name: "DotNetMetadata",
            dependencies: [ "DotNetMetadataFormat" ],
            exclude: ["CMakeLists.txt"]),
        .testTarget(
            name: "DotNetMetadataTests",
            dependencies: [
                "DotNetMetadata",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/DotNetMetadata",
            linkerSettings: executableLinkerSettings),

        .target(
            name: "WindowsMetadata",
            dependencies: [ "DotNetMetadata" ],
            exclude: ["CMakeLists.txt"]),
        .testTarget(
            name: "WindowsMetadataTests",
            dependencies: [
                "WindowsMetadata",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/WindowsMetadata",
            linkerSettings: executableLinkerSettings),

        .target(
            name: "DotNetXMLDocs",
            exclude: ["CMakeLists.txt"]),
        .testTarget(
            name: "DotNetXMLDocsTests",
            dependencies: [
                "DotNetXMLDocs",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/DotNetXMLDocs",
            linkerSettings: executableLinkerSettings),

        .target(
            name: "DotNetXMLDocsFromMetadata",
            dependencies: [ "DotNetMetadata", "DotNetXMLDocs" ],
            exclude: ["CMakeLists.txt"]),
    ]
)

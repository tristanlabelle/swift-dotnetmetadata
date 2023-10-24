// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "DotNetMetadata",
    products: [
        .library(
            name: "DotNetMetadata",
            targets: ["DotNetMetadataFormat", "DotNetMetadata", "DotNetXMLDocs", "WindowsMetadata"])
    ],
    targets: [
        .target(
            name: "CInterop"),
        .target(
            name: "DotNetMetadataFormat",
            dependencies: [ "CInterop" ]),
        .target(
            name: "DotNetMetadata",
            dependencies: [ "DotNetMetadataFormat" ]),
        .target(
            name: "WindowsMetadata",
            dependencies: [ "DotNetMetadata" ]),
        .target(
            name: "DotNetXMLDocs"),
        .testTarget(
            name: "UnitTests",
            dependencies: [ "DotNetMetadataFormat", "DotNetMetadata", "DotNetXMLDocs", "WindowsMetadata" ],
            // Workaround for SPM library support limitations causing "LNK4217: locally defined symbol imported" spew
            linkerSettings: [ .unsafeFlags(["-Xlinker", "-ignore:4217"]) ])
    ]
)

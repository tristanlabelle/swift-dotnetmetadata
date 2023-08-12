// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "DotNetMetadata",
    products: [
        .library(
            name: "DotNetMetadata",
            targets: ["DotNetMetadataFormat", "DotNetMetadata", "DotNetXMLDocs"])
    ],
    targets: [
        .target(
            name: "CInterop"),
        .target(
            name: "DotNetMetadataFormat",
            dependencies: [ "CInterop" ]),
        .target(
            name: "DotNetXMLDocs"),
        .target(
            name: "DotNetMetadata",
            dependencies: [ "DotNetMetadataFormat" ]),
        .executableTarget(
            name: "LocalTesting",
            dependencies: [ "DotNetMetadata", "DotNetMetadataFormat", "DotNetXMLDocs" ]),
        .testTarget(
            name: "UnitTests",
            dependencies: [ "DotNetMetadataFormat", "DotNetMetadata", "DotNetXMLDocs" ])
    ]
)

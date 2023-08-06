// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "DotNetMetadata",
    products: [
        .library(
            name: "DotNetMetadata",
            targets: ["DotNetMetadataFormat", "DotNetMetadata"])
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
        .testTarget(
            name: "UnitTests",
            dependencies: [ "DotNetMetadataFormat", "DotNetMetadata" ])
    ]
)

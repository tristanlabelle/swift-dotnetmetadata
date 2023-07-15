// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "DotNetMD",
    products: [
        .library(
            name: "DotNetMD",
            targets: ["DotNetMDFormat", "DotNetMD"])
    ],
    targets: [
        .target(
            name: "CInterop"),
        .target(
            name: "DotNetMDFormat",
            dependencies: [ "CInterop" ]),
        .target(
            name: "DotNetMD",
            dependencies: [ "DotNetMDFormat" ]),
        .testTarget(
            name: "UnitTests",
            dependencies: [ "DotNetMDFormat", "DotNetMD" ])
    ]
)

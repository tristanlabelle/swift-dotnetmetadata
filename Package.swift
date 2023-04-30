// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WinMD",
    products: [
        .executable(
            name: "WinMD",
            targets: ["WinMD"]),
    ],
    targets: [
        .executableTarget(
            name: "WinMD"),
        // .testTarget(
        //     name: "WinMDTests",
        //     dependencies: ["WinMD"]),
    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Y_SwiftUIAlert",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Y_SwiftUIAlert",
            targets: ["Y_SwiftUIAlert"]),
    ],
    dependencies: [
        // 不需要外部依赖
    ],
    targets: [
        .target(
            name: "Y_SwiftUIAlert",
            dependencies: [],
            path: "Sources/Y_SwiftUIAlert"
        ),
        .testTarget(
            name: "Y_SwiftUIAlertTests",
            dependencies: ["Y_SwiftUIAlert"],
            path: "Tests/Y_SwiftUIAlertTests"
        ),
    ]
)

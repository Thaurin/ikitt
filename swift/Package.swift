// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "iKITTLogic",
    products: [
        .library(name: "iKITTLogic", targets: ["iKITTLogic"])
    ],
    targets: [
        .target(
            name: "iKITTLogic",
            path: "iKITT/Core"
        ),
        .testTarget(
            name: "iKITTLogicTests",
            dependencies: ["iKITTLogic"],
            path: "Tests/iKITTLogicTests"
        )
    ]
)

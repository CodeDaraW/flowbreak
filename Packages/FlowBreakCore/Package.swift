// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FlowBreakCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "FlowBreakCore", targets: ["FlowBreakCore"]),
        .library(name: "FlowBreakMac", targets: ["FlowBreakMac"])
    ],
    targets: [
        .target(name: "FlowBreakCore"),
        .target(name: "FlowBreakMac", dependencies: ["FlowBreakCore"]),
        .testTarget(name: "FlowBreakMacTests", dependencies: ["FlowBreakMac", "FlowBreakCore"]),
        .testTarget(name: "FlowBreakCoreTests", dependencies: ["FlowBreakCore"])
    ]
)

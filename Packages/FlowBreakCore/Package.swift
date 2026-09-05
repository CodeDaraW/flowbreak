// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FlowBreakCore",
    platforms: [.macOS(.v14)],
    products: [.library(name: "FlowBreakCore", targets: ["FlowBreakCore"])],
    targets: [
        .target(name: "FlowBreakCore"),
        .testTarget(name: "FlowBreakCoreTests", dependencies: ["FlowBreakCore"])
    ]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Components",
    platforms: [
        .iOS(.v17),
        .tvOS(.v15),
        .macOS(.v15),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SwiftUIComponents", targets: ["SwiftUIComponents"])
    ],
    targets: [
        .target(name: "SwiftUIComponents"),
        .testTarget(name: "ComponentsTests", dependencies: ["SwiftUIComponents"])
    ]
)

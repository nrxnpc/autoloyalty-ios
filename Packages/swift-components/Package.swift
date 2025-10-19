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
    dependencies: [
        .package(url: "https://github.com/fermoya/SwiftUIPager.git", from: "2.5.0")
    ],
    targets: [
        .target(name: "SwiftUIComponents", dependencies: ["SwiftUIPager"]),
        .testTarget(name: "ComponentsTests", dependencies: ["SwiftUIComponents"])
    ]
)

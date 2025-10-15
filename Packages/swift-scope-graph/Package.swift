// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ScopeGraph",
    platforms: [
        .iOS(.v17),
        .tvOS(.v15),
        .macOS(.v15),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "ScopeGraph", targets: ["ScopeGraph"]),
    ],
    targets: [
        .target(
            name: "ScopeGraph",
            path: "Source/ScopeGraph"
        ),
        .testTarget(
            name: "ScopeGraphTests", 
            dependencies: ["ScopeGraph"],
            path: "Tests/ScopeGraphTests"
        )
    ]
)

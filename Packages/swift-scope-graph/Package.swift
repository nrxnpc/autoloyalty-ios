// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ScopeGraph",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11),
        .tvOS(.v18),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "ScopeGraph", targets: ["ScopeGraph"]),
    ],
    targets: [
        .target(
            name: "ScopeGraph",
            path: "Source/ScopeGraph",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ScopeGraphTests", 
            dependencies: ["ScopeGraph"],
            path: "Tests/ScopeGraphTests"
        )
    ]
)

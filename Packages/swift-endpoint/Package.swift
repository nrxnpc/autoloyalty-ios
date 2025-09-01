// swift-tools-version: 6.0
import Foundation
import PackageDescription

let excludeUITargets = ProcessInfo.processInfo.environment["EXCLUDE_UI_TARGETS"] == "1"

var products: [Product] = [
    .library(name: "Endpoint", targets: ["Endpoint"])
]
if !excludeUITargets {
    products.append(.library(name: "EndpointUI", targets: ["EndpointUI"]))
}

var targets: [Target] = [
    .target(name: "Endpoint"),
    .testTarget(
        name: "EndpointTests", 
        dependencies: ["Endpoint"],
        path: "Tests/EndpointTests"
    )
]

if !excludeUITargets {
    targets.append(
        .target(name: "EndpointUI",
            dependencies: [
                "Endpoint",
                .product(name: "Pulse", package: "Pulse"),
                .product(name: "PulseProxy", package: "Pulse"),
                .product(name: "PulseUI", package: "Pulse")
            ])
    )
}

let package = Package(
    name: "Endpoint",
    platforms: [
        .iOS(.v17),
        .tvOS(.v15),
        .macOS(.v15),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: products,
    dependencies: [
        .package(url: "https://github.com/kean/Pulse", from: "5.1.4")
    ],
    targets: targets
)
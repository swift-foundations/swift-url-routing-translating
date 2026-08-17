// swift-tools-version: 6.3.3

import Foundation
import PackageDescription

extension String {
    static let urlRoutingTranslating: Self = "URLRoutingTranslating"
}

extension Target.Dependency {
    static var urlRoutingTranslating: Self { .target(name: .urlRoutingTranslating) }
}

extension Target.Dependency {
    static var translating: Self { .product(name: "Translating", package: "swift-translating") }
    static var translatingDependencies: Self { .product(name: "Translating Dependencies", package: "swift-translating-dependencies") }
    static var urlRouting: Self { .product(name: "URLRouting", package: "swift-url-routing") }
    static var urlRoutingFoundationIntegration: Self { .product(name: "URL Routing Foundation Integration", package: "swift-url-routing") }
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "Dependencies Test Support", package: "swift-dependencies") }
}

let package = Package(
    name: "swift-url-routing-translating",
    platforms: [
        .macOS("27"),
        .iOS("27"),
        .tvOS("27"),
        .watchOS("27"),
        .visionOS("27")
    ],
    products: [
        .library(
            name: .urlRoutingTranslating,
            targets: [.urlRoutingTranslating]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-translating.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-translating-dependencies.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-url-routing.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-dependencies.git", branch: "main")
    ],
    targets: [
        .target(
            name: .urlRoutingTranslating,
            dependencies: [
                .translating,
                .translatingDependencies,
                .urlRouting,
                .dependencies
            ]
        ),
        .testTarget(
            name: .urlRoutingTranslating.tests,
            dependencies: [
                .urlRoutingTranslating,
                .urlRoutingFoundationIntegration,
                .dependenciesTestSupport,
                .dependencies
            ],
            path: "Tests/URLRouting+Translating Tests"
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { "\(self) Tests" } }

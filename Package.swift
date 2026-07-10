// swift-tools-version: 6.3.1

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
    static var urlRouting: Self { .product(name: "URLRouting", package: "swift-url-routing") }
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "Dependencies Test Support", package: "swift-dependencies") }
}

let package = Package(
    name: "swift-url-routing-translating",
    platforms: [
        .macOS(.v26),
        .iOS(.v26)
    ],
    products: [
        .library(
            name: .urlRoutingTranslating,
            targets: [.urlRoutingTranslating]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-translating.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-url-routing.git", from: "0.6.2"),
        .package(url: "https://github.com/swift-foundations/swift-dependencies.git", branch: "main")
    ],
    targets: [
        .target(
            name: .urlRoutingTranslating,
            dependencies: [
                .translating,
                .urlRouting,
                .dependencies
            ]
        ),
        .testTarget(
            name: .urlRoutingTranslating.tests,
            dependencies: [
                .urlRoutingTranslating,
                .dependenciesTestSupport,
                .dependencies
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)

extension String { var tests: Self { "\(self) Tests" } }

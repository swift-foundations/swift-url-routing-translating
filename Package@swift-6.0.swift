// swift-tools-version:6.0

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
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: .urlRoutingTranslating,
            targets: [.urlRoutingTranslating]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/swift-translating.git", from: "0.0.1"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.9.2"),
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
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { "\(self) Tests" } }

# swift-url-routing-translating

[![CI](https://github.com/coenttb/swift-url-routing-translating/workflows/CI/badge.svg)](https://github.com/coenttb/swift-url-routing-translating/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Integrates multilingual string support with URL routing by extending [swift-translating](https://github.com/coenttb/swift-translating) to work with [swift-url-routing](https://github.com/pointfreeco/swift-url-routing).

## Overview

URLRoutingTranslating enables type-safe, multilingual URL routing in Swift applications. Parse and generate URLs in multiple languages using the same route definitions, with automatic language-aware path matching and URL generation.

## Features

- Multi-language URL support with parse and generate capabilities
- Type-safe routing with compile-time route validation
- Performance optimized with current language fast-path checking (~300k operations/sec)
- Helpful debugging utilities with rich error messages

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-url-routing-translating.git", from: "0.0.1")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "URLRoutingTranslating", package: "swift-url-routing-translating")
        ]
    )
]
```

## Quick Start

### 1. Define your translated strings

```swift
import Translating
import URLRoutingTranslating

extension TranslatedString {
    static let home: TranslatedString = [
        .english: "home",
        .dutch: "thuis"
    ]

    static let about: TranslatedString = [
        .english: "about us",
        .dutch: "over ons"
    ]
}
```

### 2. Create your router

```swift
import URLRouting

enum Route: Equatable {
    case home
    case about
}

struct AppRouter: ParserPrinter {
    var body: some URLRouting.Router<Route> {
        OneOf {
            URLRouting.Route(.case(Route.home)) {
                Path { TranslatedString.home.slug() }
            }

            URLRouting.Route(.case(Route.about)) {
                Path { TranslatedString.about.slug() }
            }
        }
    }
}
```

### 3. Parse and generate URLs

```swift
import Dependencies

let router = AppRouter()

// Set up dependencies
withDependencies {
    $0.language = .english
    $0.languages = [.english, .dutch]
} operation: {
    // Parse URLs - works for any language
    try router.match(path: "/home")        // → .home
    try router.match(path: "/thuis")       // → .home
    try router.match(path: "/about-us")    // → .about
    try router.match(path: "/over-ons")    // → .about

    // Generate URLs - uses current language
    router.url(for: .home)     // → "/home"
    router.url(for: .about)    // → "/about-us"
}

// Switch to Dutch
withDependencies {
    $0.language = .dutch
} operation: {
    router.url(for: .home)     // → "/thuis"
    router.url(for: .about)    // → "/over-ons"
}
```

## Usage

### How It Works

URLRoutingTranslating extends `TranslatedString` to conform to URLRouting's `Parser` and `ParserPrinter` protocols.

#### Parsing Behavior
- Fast-path optimization: Current language is checked first for optimal performance
- Fallback matching: If current language doesn't match, all other available languages are tried
- Helpful errors: Failed parsing provides all available translations for debugging

#### Printing Behavior
- Current language: URLs are generated using the current language from Dependencies
- URL-safe output: Use `.slug()` from swift-translating to convert spaces and special characters to URL-friendly format

#### Performance
- Parsing: ~300k operations per second with minimal overhead vs String baseline
- Multi-language scaling: Performance remains consistent regardless of language count (thanks to fast-path)
- Memory efficiency: Zero memory overhead compared to String-based routers

### API Reference

#### Core Extensions

```swift
extension TranslatedString: Parser, ParserPrinter {
    // Parses any available language translation from URL path
    func parse(_ input: inout Substring) throws -> Void

    // Generates URL using current language translation
    func print(_ output: Void, into input: inout Substring) throws
}
```

#### Usage Guidelines

1. Always use `.slug()` in router definitions to ensure URL-safe paths:
   ```swift
   Path { translatedString.slug() }  // ✅ Correct
   Path { translatedString }         // ❌ May contain spaces/special chars
   ```

2. Set up Dependencies before using routers:
   ```swift
   withDependencies {
       $0.language = .english              // Current language for URL generation
       $0.languages = [.english, .dutch]   // Available languages for parsing
   }
   ```

3. Use dictionary literals for TranslatedString creation (recommended):
   ```swift
   let home: TranslatedString = [
       .english: "home",
       .dutch: "thuis"
   ]
   ```

## Related Packages

### Dependencies

- [swift-translating](https://github.com/coenttb/swift-translating): A Swift package for inline translations.

### Used By

- [swift-types-foundation](https://github.com/coenttb/swift-types-foundation): A Swift package bundling essential type-safe packages for domain modeling.

### Third-Party Dependencies

- [pointfreeco/swift-dependencies](https://github.com/pointfreeco/swift-dependencies): A dependency management library for controlling dependencies in Swift.
- [pointfreeco/swift-url-routing](https://github.com/pointfreeco/swift-url-routing): A bidirectional URL router with more type safety and less fuss.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.

## License

This project is licensed under the Apache 2.0 License. See [LICENSE](LICENSE) for details.

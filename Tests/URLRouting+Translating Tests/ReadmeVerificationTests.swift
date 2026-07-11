//
//  ReadmeVerificationTests.swift
//  URLRoutingTranslating
//
//  Created by README standardization process
//

import Dependencies
import Dependencies_Test_Support
import Foundation
import Testing
import Translating
import URLRouting
import URLRoutingTranslating

// MARK: - README Verification Tests

// Route enum from README, hoisted to file scope so `@Cases` can synthesize its
// `.cases` witness (the macro does not apply to types nested inside a suite struct).
@Cases
enum ReadmeRoute: Equatable {
    case home
    case about
}

@Suite("README Verification")
struct ReadmeVerificationTests {

    // MARK: - Example Setup from README

    // Define translated strings as shown in README
    enum ReadmeTranslatedStrings {
        static let home: TranslatedString = [
            .english: "home",
            .dutch: "thuis",
        ]

        static let about: TranslatedString = [
            .english: "about us",
            .dutch: "over ons",
        ]
    }

    // Router from README
    struct ReadmeRouter: ParserPrinter {
        var body: some URLRouting.Router<ReadmeRoute> {
            OneOf {
                URLRouting.Route(.case(ReadmeRoute.cases.home)) {
                    Path { ReadmeTranslatedStrings.home.slug() }
                }

                URLRouting.Route(.case(ReadmeRoute.cases.about)) {
                    Path { ReadmeTranslatedStrings.about.slug() }
                }
            }
        }
    }

    // MARK: - Quick Start Example Tests

    @Test(
        "README Quick Start - Define translated strings",
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    func testDefineTranslatedStrings() async throws {
        // Example from README lines 41-58
        let home: TranslatedString = [
            .english: "home",
            .dutch: "thuis",
        ]

        let about: TranslatedString = [
            .english: "about us",
            .dutch: "over ons",
        ]

        #expect(home[.english] == "home")
        #expect(home[.dutch] == "thuis")
        #expect(about[.english] == "about us")
        #expect(about[.dutch] == "over ons")
    }

    @Test(
        "README Quick Start - Create router",
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    func testCreateRouter() async throws {
        // Example from README lines 60-83
        let router = ReadmeRouter()

        // Verify router exists and can be used
        #expect(type(of: router) == ReadmeRouter.self)
    }

    @Test(
        "README Quick Start - Parse URLs in any language",
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    func testParseURLsInAnyLanguage() async throws {
        // Example from README lines 87-115
        let router = ReadmeRouter()

        try withDependencies {
            $0.language = .english
            $0.languages = [.english, .dutch]
        } operation: {
            // Parse URLs - works for any language
            let homeEnglish = try router.match(path: "/home")
            #expect(homeEnglish == .home)

            let homeDutch = try router.match(path: "/thuis")
            #expect(homeDutch == .home)

            let aboutEnglish = try router.match(path: "/about-us")
            #expect(aboutEnglish == .about)

            let aboutDutch = try router.match(path: "/over-ons")
            #expect(aboutDutch == .about)
        }
    }

    @Test(
        "README Quick Start - Generate URLs in current language",
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    func testGenerateURLsInCurrentLanguage() async throws {
        // Example from README lines 87-115
        let router = ReadmeRouter()

        withDependencies {
            $0.language = .english
            $0.languages = [.english, .dutch]
        } operation: {
            // Generate URLs - uses current language
            #expect(router.url(for: .home).description == "/home")
            #expect(router.url(for: .about).description == "/about-us")
        }
    }

    @Test(
        "README Quick Start - Switch to Dutch",
        .dependency(\.language, .dutch),
        .dependency(\.languages, [.english, .dutch])
    )
    func testSwitchToDutch() async throws {
        // Example from README lines 108-115
        let router = ReadmeRouter()

        withDependencies {
            $0.language = .dutch
        } operation: {
            #expect(router.url(for: .home).description == "/thuis")
            #expect(router.url(for: .about).description == "/over-ons")
        }
    }

    // MARK: - API Reference Examples

    @Test(
        "README API - Core Extensions exist",
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    func testCoreExtensionsExist() async throws {
        // Example from README lines 139-149
        let translatedString = ReadmeTranslatedStrings.home

        // Verify TranslatedString conforms to Parser.Protocol and Parser.Bidirectional
        // (the component-level surface `Path { }` actually requires post-rewrite;
        // the pre-rewrite check was against the old generic, Failure-unpinned
        // top-level `Parser`/`ParserPrinter` protocols, which no longer exist).
        let _: any Parser.`Protocol`<Substring, Void, TranslatedStringParsingError> = translatedString
        let _: any Parser.Bidirectional<Substring, Void, TranslatedStringParsingError> = translatedString

        // Verify parse method exists
        var input = Substring("home")
        try translatedString.parse(&input)
        #expect(input.isEmpty)

        // Verify print method exists
        var output = Substring("")
        try translatedString.print((), into: &output)
        #expect(output == "home")
    }

    @Test(
        "README API - Always use .slug()",
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    func testAlwaysUseSlug() async throws {
        // Example from README lines 153-157
        let translatedString = ReadmeTranslatedStrings.about

        // Test that slug() creates URL-friendly strings
        let slugified = translatedString.slug()
        #expect(slugified[.english] == "about-us")
        #expect(slugified[.dutch] == "over-ons")

        // Verify slugified version can be parsed
        var input = Substring("about-us")
        try slugified.parse(&input)
        #expect(input.isEmpty)
    }

    @Test(
        "README API - Set up Dependencies",
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    func testSetUpDependencies() async throws {
        // Example from README lines 159-165
        @Dependency(\.language) var currentLanguage
        @Dependency(\.languages) var availableLanguages

        withDependencies {
            $0.language = .english
            $0.languages = [.english, .dutch]
        } operation: {
            @Dependency(\.language) var language
            @Dependency(\.languages) var languages

            #expect(language == .english)
            #expect(languages == [.english, .dutch])
        }
    }

    @Test(
        "README API - Use dictionary literals",
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    func testUseDictionaryLiterals() async throws {
        // Example from README lines 167-173
        let home: TranslatedString = [
            .english: "home",
            .dutch: "thuis",
        ]

        #expect(home[.english] == "home")
        #expect(home[.dutch] == "thuis")
    }

    // MARK: - Integration Tests

    @Test(
        "README Full Example - Complete workflow",
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    func testCompleteWorkflow() async throws {
        // This test verifies the complete README example works end-to-end
        let router = ReadmeRouter()

        // Test English workflow
        try withDependencies {
            $0.language = .english
            $0.languages = [.english, .dutch]
        } operation: {
            // Parse both English and Dutch URLs
            let homeFromEnglish = try router.match(path: "/home")
            let homeFromDutch = try router.match(path: "/thuis")
            #expect(homeFromEnglish == .home)
            #expect(homeFromDutch == .home)

            // Generate English URLs
            let homeURL = router.url(for: .home)
            let aboutURL = router.url(for: .about)
            #expect(homeURL.description == "/home")
            #expect(aboutURL.description == "/about-us")
        }

        // Test Dutch workflow
        try withDependencies {
            $0.language = .dutch
            $0.languages = [.english, .dutch]
        } operation: {
            // Parse both languages still works
            let homeFromEnglish = try router.match(path: "/home")
            let homeFromDutch = try router.match(path: "/thuis")
            #expect(homeFromEnglish == .home)
            #expect(homeFromDutch == .home)

            // Generate Dutch URLs
            let homeURL = router.url(for: .home)
            let aboutURL = router.url(for: .about)
            #expect(homeURL.description == "/thuis")
            #expect(aboutURL.description == "/over-ons")
        }
    }

    @Test(
        "README Performance Claims - Parsing speed",
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    func testParsingPerformance() async throws {
        // Verify that parsing works efficiently as claimed in README line 16 and 133
        let router = ReadmeRouter()
        let iterations = 1000

        let start = Date()
        for _ in 0..<iterations {
            _ = try router.match(path: "/home")
            _ = try router.match(path: "/about-us")
        }
        let duration = Date().timeIntervalSince(start)

        // Should complete 2000 operations in reasonable time
        // Even at 10k ops/sec this should take < 0.2 seconds
        #expect(duration < 1.0, "Parsing took \(duration)s for \(iterations * 2) operations")
    }
}

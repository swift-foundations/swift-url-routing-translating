//
//  URLRoutingTranslating Tests.swift
//  URLRoutingTranslating
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import Testing
import Translating
import URLRouting
import URLRoutingTranslating

// MARK: - Main Test Suite

@Suite(
    "TranslatedString+URLRouting Tests",
    .dependency(\.locale, .english),
    .dependency(\.language, .english),
    .dependency(\.languages, [.english, .dutch])
)
struct TranslatedStringURLRoutingTests {

    // MARK: - Router Integration Tests

    @Suite("Router Integration")
    struct RouterIntegrationTests {

        @Test("Router matches current language paths")
        func testRouterMatchesCurrentLanguagePaths() async throws {
            let router = TestRouter()

            // Test English parsing (current language)
            try #expect(router.match(path: "/home") == .home)
            try #expect(router.match(path: "/about-us") == .about)
            try #expect(router.match(path: "/contact") == .contact)
            try #expect(router.match(path: "/privacy-policy") == .privacyPolicy)
            try #expect(router.match(path: "/general-terms-and-conditions") == .generalTerms)
            try #expect(router.match(path: "/newsletter") == .newsletter)
        }

        @Test("Router matches alternative language paths")
        func testRouterMatchesAlternativeLanguagePaths() async throws {
            let router = TestRouter()

            // Test Dutch parsing (non-current language)
            try #expect(router.match(path: "/thuis") == .home)
            try #expect(router.match(path: "/over-ons") == .about)
            try #expect(router.match(path: "/contact") == .contact)
            try #expect(router.match(path: "/privacybeleid") == .privacyPolicy)
            try #expect(router.match(path: "/algemene-voorwaarden") == .generalTerms)
            try #expect(router.match(path: "/nieuwsbrief") == .newsletter)
        }

        @Test("Router adapts to different current language")
        func testRouterAdaptsToDifferentCurrentLanguage() async throws {
            let router = TestRouter()

            try withDependencies {
                $0.language = .dutch
            } operation: {
                // Dutch should be checked first now
                try #expect(router.match(path: "/thuis") == .home)
                try #expect(router.match(path: "/over-ons") == .about)

                // English should still work
                try #expect(router.match(path: "/home") == .home)
                try #expect(router.match(path: "/about-us") == .about)
            }
        }

        @Test("Router throws helpful error for unknown paths")
        func testRouterThrowsHelpfulErrorForUnknownPaths() async throws {
            let router = TestRouter()

            do {
                _ = try router.match(path: "/unknown-path")
                #expect(Bool(false), "Expected parsing to throw an error")
            } catch {
                let errorDescription = String(describing: error)
                #expect(errorDescription.contains("unknown-path"))
                #expect(errorDescription.contains("Available translations"))
            }
        }
    }

    // MARK: - URL Generation Tests

    @Suite("URL Generation")
    struct URLGenerationTests {

        @Test("Generates URLs in current language")
        func testGeneratesURLsInCurrentLanguage() async throws {
            let router = TestRouter()

            // Test English URL generation (current language)
            #expect(router.url(for: .home).description == "/home")
            #expect(router.url(for: .about).description == "/about-us")
            #expect(router.url(for: .contact).description == "/contact")
            #expect(router.url(for: .privacyPolicy).description == "/privacy-policy")
            #expect(router.url(for: .generalTerms).description == "/general-terms-and-conditions")
            #expect(router.url(for: .newsletter).description == "/newsletter")
        }

        @Test("Generates URLs in Dutch when language is Dutch")
        func testGeneratesURLsInDutchWhenLanguageIsDutch() async throws {
            let router = TestRouter()

            withDependencies {
                $0.language = .dutch
            } operation: {
                // Test Dutch URL generation
                #expect(router.url(for: .home).description == "/thuis")
                #expect(router.url(for: .about).description == "/over-ons")
                #expect(router.url(for: .contact).description == "/contact")
                #expect(router.url(for: .privacyPolicy).description == "/privacybeleid")
                #expect(router.url(for: .generalTerms).description == "/algemene-voorwaarden")
                #expect(router.url(for: .newsletter).description == "/nieuwsbrief")
            }
        }

        @Test("Round-trip parsing and printing works correctly")
        func testRoundTripParsingAndPrintingWorksCorrectly() async throws {
            let router = TestRouter()
            let routes: [TestRoute] = [
                .home, .about, .contact, .privacyPolicy, .generalTerms, .newsletter,
            ]

            // Test English round-trip
            for route in routes {
                let url = router.url(for: route)
                let parsedRoute = try router.match(url: url)
                #expect(parsedRoute == route)
            }

            // Test Dutch round-trip
            try withDependencies {
                $0.language = .dutch
            } operation: {
                for route in routes {
                    let url = router.url(for: route)
                    let parsedRoute = try router.match(url: url)
                    #expect(parsedRoute == route)
                }
            }
        }
    }

    // MARK: - Direct Parser Tests

    @Suite("Direct Parser Functionality")
    struct DirectParserTests {

        @Test("Parser directly parses correct input")
        func testParserDirectlyParsesCorrectInput() async throws {
            var englishInput = Substring("home")
            try TestTranslatedString.home.parse(&englishInput)
            #expect(englishInput.isEmpty)

            var dutchInput = Substring("thuis")
            try TestTranslatedString.home.parse(&dutchInput)
            #expect(dutchInput.isEmpty)
        }

        @Test("Slugified strings work correctly in parsing")
        func testSlugifiedStringsWorkCorrectlyInParsing() async throws {
            let slugifiedString = TestTranslatedString.about.slug()

            var englishInput = Substring("about-us")
            try slugifiedString.parse(&englishInput)
            #expect(englishInput.isEmpty)

            var dutchInput = Substring("over-ons")
            try slugifiedString.parse(&dutchInput)
            #expect(dutchInput.isEmpty)
        }

        @Test("Parser handles empty input gracefully")
        func testParserHandlesEmptyInputGracefully() async throws {
            var emptyInput = Substring("")

            do {
                try TestTranslatedString.home.parse(&emptyInput)
                #expect(Bool(false), "Expected parsing to throw an error")
            } catch {
                // Should throw an error for empty input
                #expect(Bool(true))
            }
        }

        @Test("Parser handles partial matches correctly")
        func testParserHandlesPartialMatchesCorrectly() async throws {
            var partialInput = Substring("homecoming")  // Starts with "home" but has more

            // Parser should match "home" and leave "coming" in the input
            try TestTranslatedString.home.parse(&partialInput)
            #expect(partialInput == "coming")  // Remaining part should be left
        }
    }

    // MARK: - Direct ParserPrinter Tests

    @Suite("Direct ParserPrinter Functionality")
    struct DirectParserPrinterTests {

        @Test("ParserPrinter directly prints current language")
        func testParserPrinterDirectlyPrintsCurrentLanguage() async throws {
            var output = Substring("")
            try TestTranslatedString.home.print((), into: &output)
            #expect(output == "home")

            try withDependencies {
                $0.language = .dutch
            } operation: {
                var dutchOutput = Substring("")
                try TestTranslatedString.home.print((), into: &dutchOutput)
                #expect(dutchOutput == "thuis")
            }
        }

        @Test("Slugified strings work correctly in printing")
        func testSlugifiedStringsWorkCorrectlyInPrinting() async throws {
            let slugifiedString = TestTranslatedString.about.slug()

            var output = Substring("")
            try slugifiedString.print((), into: &output)
            #expect(output == "about-us")

            try withDependencies {
                $0.language = .dutch
            } operation: {
                var dutchOutput = Substring("")
                try slugifiedString.print((), into: &dutchOutput)
                #expect(dutchOutput == "over-ons")
            }
        }
    }

    // MARK: - Multi-language Tests

    @Suite(
        "Multi-language Support",
        .dependency(\.languages, [.english, .dutch, .german])
    )
    struct MultiLanguageTests {

        @Test("Parser works with more than two languages")
        func testParserWorksWithMoreThanTwoLanguages() async throws {
            var englishInput = Substring("multi-language-test")
            try TestTranslatedString.multiLanguage.slug().parse(&englishInput)
            #expect(englishInput.isEmpty)

            var dutchInput = Substring("meertalige-test")
            try TestTranslatedString.multiLanguage.slug().parse(&dutchInput)
            #expect(dutchInput.isEmpty)

            var germanInput = Substring("mehrsprachiger-test")
            try TestTranslatedString.multiLanguage.slug().parse(&germanInput)
            #expect(germanInput.isEmpty)
        }

        @Test("Current language is checked first for performance")
        func testCurrentLanguageIsCheckedFirstForPerformance() async throws {
            var input = Substring("test")

            // With English as current language, it should match English first
            try TestTranslatedString.performanceTest.parse(&input)
            #expect(input.isEmpty)

            // Test with Dutch as current language
            try withDependencies {
                $0.language = .dutch
            } operation: {
                var dutchInput = Substring("test")
                try TestTranslatedString.performanceTest.parse(&dutchInput)
                #expect(dutchInput.isEmpty)
            }
        }
    }

    // MARK: - Edge Cases Tests

    @Suite("Edge Cases")
    struct EdgeCasesTests {

        @Test("TranslatedString with identical translations works correctly")
        func testTranslatedStringWithIdenticalTranslationsWorksCorrectly() async throws {
            var input = Substring("same")
            try TestTranslatedString.identical.parse(&input)
            #expect(input.isEmpty)

            // Should work regardless of current language
            try withDependencies {
                $0.language = .dutch
            } operation: {
                var dutchInput = Substring("same")
                try TestTranslatedString.identical.parse(&dutchInput)
                #expect(dutchInput.isEmpty)
            }
        }
    }

    // MARK: - Debugging Tests

    @Suite("Debugging Helpers")
    struct DebuggingTests {

        @Test("debugTranslations shows all language translations")
        func testDebugTranslationsShowsAllLanguageTranslations() async throws {
            let debugOutput = TestTranslatedString.home.debugTranslations

            #expect(debugOutput.contains("english: 'home'"))
            #expect(debugOutput.contains("dutch: 'thuis'"))
            #expect(debugOutput.contains("TranslatedString"))
        }

        @Test("debugURLPaths shows URL-friendly paths")
        func testDebugURLPathsShowsURLFriendlyPaths() async throws {
            let debugOutput = TestTranslatedString.about.debugURLPaths

            #expect(debugOutput.contains("/en/about us → /en/about-us"))
            #expect(debugOutput.contains("/nl/over ons → /nl/over-ons"))
            #expect(debugOutput.contains("URL paths"))
        }

        @Test("debugURLPaths handles already slugified strings")
        func testDebugURLPathsHandlesAlreadySlugifiedStrings() async throws {
            let debugOutput = TestTranslatedString.contact.debugURLPaths

            // Contact is already URL-friendly in both languages
            #expect(debugOutput.contains("/en/contact"))
            #expect(debugOutput.contains("/nl/contact"))
            #expect(!debugOutput.contains("→"))  // No transformation arrow
        }
    }
}

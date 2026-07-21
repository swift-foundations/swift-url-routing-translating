//
//  URLRoutingTranslating Tests.swift
//  URLRoutingTranslating
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

import Dependencies
import Dependencies_Test_Support
import Foundation
import Testing
import Translating
import URLRouting
import URLRoutingTranslating

// MARK: - Main Test Suite

@Suite(

    .dependency(\.language, .english),
    .dependency(\.languages, [.english, .dutch])
)
struct `URLRouting Translating` {

    // MARK: - Router Integration Tests

    @Suite
    struct `Router Integration` {

        @Test
        func `Router matches current language paths`() async throws {
            let router = TestRouter()

            // Test English parsing (current language)
            try #expect(router.match(path: "/home") == .home)
            try #expect(router.match(path: "/about-us") == .about)
            try #expect(router.match(path: "/contact") == .contact)
            try #expect(router.match(path: "/privacy-policy") == .privacyPolicy)
            try #expect(router.match(path: "/general-terms-and-conditions") == .generalTerms)
            try #expect(router.match(path: "/newsletter") == .newsletter)
        }

        @Test
        func `Router matches alternative language paths`() async throws {
            let router = TestRouter()

            // Test Dutch parsing (non-current language)
            try #expect(router.match(path: "/thuis") == .home)
            try #expect(router.match(path: "/over-ons") == .about)
            try #expect(router.match(path: "/contact") == .contact)
            try #expect(router.match(path: "/privacybeleid") == .privacyPolicy)
            try #expect(router.match(path: "/algemene-voorwaarden") == .generalTerms)
            try #expect(router.match(path: "/nieuwsbrief") == .newsletter)
        }

        @Test
        func `Router adapts to different current language`() async throws {
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

        @Test
        func `Router throws helpful error for unknown paths`() async throws {
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

    @Suite
    struct `URL Generation` {

        @Test
        func `Generates URLs in current language`() async throws {
            let router = TestRouter()

            // Test English URL generation (current language)
            #expect(router.url(for: .home).description == "/home")
            #expect(router.url(for: .about).description == "/about-us")
            #expect(router.url(for: .contact).description == "/contact")
            #expect(router.url(for: .privacyPolicy).description == "/privacy-policy")
            #expect(router.url(for: .generalTerms).description == "/general-terms-and-conditions")
            #expect(router.url(for: .newsletter).description == "/newsletter")
        }

        @Test
        func `Generates URLs in Dutch when language is Dutch`() async throws {
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

        @Test
        func `Round-trip parsing and printing works correctly`() async throws {
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

    @Suite
    struct `Direct Parser` {

        @Test
        func `Parser directly parses correct input`() async throws {
            var englishInput = Substring("home")
            try TestTranslatedString.home.parse(&englishInput)
            #expect(englishInput.isEmpty)

            var dutchInput = Substring("thuis")
            try TestTranslatedString.home.parse(&dutchInput)
            #expect(dutchInput.isEmpty)
        }

        @Test
        func `Slugified strings work correctly in parsing`() async throws {
            let slugifiedString = TestTranslatedString.about.slug()

            var englishInput = Substring("about-us")
            try slugifiedString.parse(&englishInput)
            #expect(englishInput.isEmpty)

            var dutchInput = Substring("over-ons")
            try slugifiedString.parse(&dutchInput)
            #expect(dutchInput.isEmpty)
        }

        @Test
        func `Parser handles empty input gracefully`() async throws {
            var emptyInput = Substring("")

            do {
                try TestTranslatedString.home.parse(&emptyInput)
                #expect(Bool(false), "Expected parsing to throw an error")
            } catch {
                // Should throw an error for empty input
                #expect(Bool(true))
            }
        }

        @Test
        func `Parser handles partial matches correctly`() async throws {
            var partialInput = Substring("homecoming")  // Starts with "home" but has more

            // Parser should match "home" and leave "coming" in the input
            try TestTranslatedString.home.parse(&partialInput)
            #expect(partialInput == "coming")  // Remaining part should be left
        }
    }

    // MARK: - Direct ParserPrinter Tests

    @Suite
    struct `Direct ParserPrinter` {

        @Test
        func `Parser Printer directly prints current language`() async throws {
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

        @Test
        func `Slugified strings work correctly in printing`() async throws {
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

        .dependency(\.languages, [.english, .dutch, .german])
    )
    struct `Multi-language` {

        @Test
        func `Parser works with more than two languages`() async throws {
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

        @Test
        func `Current language is checked first for performance`() async throws {
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

    @Suite
    struct `Edge Cases` {

        @Test
        func `Translated String with identical translations works correctly`() async throws {
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

    @Suite
    struct `Debugging` {

        @Test
        func `Debug Translations shows all language translations`() async throws {
            let debugOutput = TestTranslatedString.home.debugTranslations

            #expect(debugOutput.contains("en: 'home'"))
            #expect(debugOutput.contains("nl: 'thuis'"))
            #expect(debugOutput.contains("TranslatedString"))
        }

        @Test
        func `Debug URLPaths shows URL-friendly paths`() async throws {
            let debugOutput = TestTranslatedString.about.debugURLPaths

            #expect(debugOutput.contains("/en/about us → /en/about-us"))
            #expect(debugOutput.contains("/nl/over ons → /nl/over-ons"))
            #expect(debugOutput.contains("URL paths"))
        }

        @Test
        func `Debug URLPaths handles already slugified strings`() async throws {
            let debugOutput = TestTranslatedString.contact.debugURLPaths

            // Contact is already URL-friendly in both languages
            #expect(debugOutput.contains("/en/contact"))
            #expect(debugOutput.contains("/nl/contact"))
            #expect(!debugOutput.contains("→"))  // No transformation arrow
        }
    }
}

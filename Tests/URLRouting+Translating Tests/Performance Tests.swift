//
//  Performance Tests.swift
//  URLRoutingTranslating Tests
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

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#endif

@Suite(
    "URLRoutingTranslating Performance Tests",
    .serialized,
    .disabled("Enable for performance testing")
)
struct URLRoutingTranslatingPerformanceTests {

    // MARK: - Parsing Performance Tests

    @Suite(
        "Parsing Performance - TranslatedString vs String",
        .serialized,
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    struct ParsingPerformanceTests {

        @Test("String literal parsing performance (baseline)")
        func stringLiteralParsingPerformance() throws {
            let iterations = 10_000
            let testInput = "home"
            let clock = ContinuousClock()

            let result = clock.measure {
                for _ in 0..<iterations {
                    var input = Substring(testInput)
                    if input.hasPrefix("home") {
                        input.removeFirst("home".count)
                    }
                }
            }

            let timeInSeconds =
                Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
            let operationsPerSecond = Double(iterations) / timeInSeconds

            print("📊 BASELINE - String Literal Parsing Performance:")
            print("   Time: \(result)")
            print("   Time (seconds): \(timeInSeconds)")
            print("   Iterations: \(iterations)")
            print("   Operations per second: \(String(format: "%.0f", operationsPerSecond))")
            print(
                "   Average time per operation: \(String(format: "%.2f", timeInSeconds / Double(iterations) * 1_000_000))μs"
            )
            print("   ✅ This is our baseline for comparison")

            #expect(result < .seconds(1), "String parsing should be very fast")
        }

        @Test("TranslatedString parsing performance - Current language match")
        func translatedStringParsingCurrentLanguagePerformance() throws {
            let iterations = 10_000
            let testInput = "home"
            let translatedString = TestTranslatedString.home
            let clock = ContinuousClock()

            let result = clock.measure {
                for _ in 0..<iterations {
                    var input = Substring(testInput)
                    try? translatedString.parse(&input)
                }
            }

            let timeInSeconds =
                Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
            let operationsPerSecond = Double(iterations) / timeInSeconds

            print("📊 PERFORMANCE - TranslatedString Parsing (Current Language Match):")
            print("   Time: \(result)")
            print("   Time (seconds): \(timeInSeconds)")
            print("   Iterations: \(iterations)")
            print("   Operations per second: \(String(format: "%.0f", operationsPerSecond))")
            print(
                "   Average time per operation: \(String(format: "%.2f", timeInSeconds / Double(iterations) * 1_000_000))μs"
            )
            print("   ⚡️ Fast path - current language checked first")

            #expect(result < .seconds(2), "TranslatedString parsing should be reasonably fast")
        }

        @Test("TranslatedString parsing performance - Alternative language match")
        func translatedStringParsingAlternativeLanguagePerformance() throws {
            let iterations = 10_000
            let testInput = "thuis"  // Dutch word, will be checked after English
            let translatedString = TestTranslatedString.home
            let clock = ContinuousClock()

            let result = clock.measure {
                for _ in 0..<iterations {
                    var input = Substring(testInput)
                    try? translatedString.parse(&input)
                }
            }

            let timeInSeconds =
                Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
            let operationsPerSecond = Double(iterations) / timeInSeconds

            print("📊 PERFORMANCE - TranslatedString Parsing (Alternative Language Match):")
            print("   Time: \(result)")
            print("   Time (seconds): \(timeInSeconds)")
            print("   Iterations: \(iterations)")
            print("   Operations per second: \(String(format: "%.0f", operationsPerSecond))")
            print(
                "   Average time per operation: \(String(format: "%.2f", timeInSeconds / Double(iterations) * 1_000_000))μs"
            )
            print("   🐌 Slower path - alternative language match")

            #expect(
                result < .seconds(3),
                "Alternative language matching should still be reasonable"
            )
        }

        @Test("Performance comparison - String vs TranslatedString parsing")
        func performanceComparisonStringVsTranslatedString() throws {
            let iterations = 10_000
            let testInput = "home"

            // Baseline: String parsing
            let stringResult = ContinuousClock().measure {
                for _ in 0..<iterations {
                    var input = Substring(testInput)
                    if input.hasPrefix("home") {
                        input.removeFirst("home".count)
                    }
                }
            }

            // TranslatedString parsing
            let translatedStringResult = ContinuousClock().measure {
                for _ in 0..<iterations {
                    var input = Substring(testInput)
                    try? TestTranslatedString.home.parse(&input)
                }
            }

            let stringTimeInSeconds =
                Double(stringResult.components.seconds) + Double(
                    stringResult.components.attoseconds
                ) / 1e18
            let translatedTimeInSeconds =
                Double(translatedStringResult.components.seconds) + Double(
                    translatedStringResult.components.attoseconds
                ) / 1e18
            let performanceRatio = translatedTimeInSeconds / stringTimeInSeconds

            print("📊 PERFORMANCE COMPARISON - String vs TranslatedString Parsing:")
            print("   String Time: \(stringResult)")
            print("   String Time (seconds): \(stringTimeInSeconds)")
            print(
                "   String Ops/sec: \(String(format: "%.0f", Double(iterations) / stringTimeInSeconds))"
            )
            print("   TranslatedString Time: \(translatedStringResult)")
            print("   TranslatedString Time (seconds): \(translatedTimeInSeconds)")
            print(
                "   TranslatedString Ops/sec: \(String(format: "%.0f", Double(iterations) / translatedTimeInSeconds))"
            )
            print("   Performance ratio: \(String(format: "%.2f", performanceRatio))x")
            print(
                "   TranslatedString is \(String(format: "%.2f", performanceRatio))x slower than String"
            )
            print(
                "   Overhead per operation: \(String(format: "%.2f", (translatedTimeInSeconds - stringTimeInSeconds) / Double(iterations) * 1_000_000))μs"
            )

            #expect(
                performanceRatio < 10.0,
                "TranslatedString should not be more than 10x slower than String"
            )
        }
    }

    // MARK: - Multi-language Performance Tests

    @Suite(
        "Multi-language Parsing Performance",
        .serialized,
        .dependency(\.language, .english)
    )
    struct MultiLanguagePerformanceTests {

        @Test("Performance with 2 languages (English + Dutch)")
        func performanceWithTwoLanguages() throws {
            let iterations = 5_000
            let testInput = "thuis"  // Dutch word
            let translatedString = TestTranslatedString.home
            let clock = ContinuousClock()

            let result = clock.measure {
                withDependencies {
                    $0.languages = [.english, .dutch]
                } operation: {
                    for _ in 0..<iterations {
                        var input = Substring(testInput)
                        try? translatedString.parse(&input)
                    }
                }
            }

            let timeInSeconds =
                Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18

            print("📊 PERFORMANCE - 2 Languages (English + Dutch):")
            print("   Time: \(result)")
            print("   Time (seconds): \(timeInSeconds)")
            print(
                "   Operations per second: \(String(format: "%.0f", Double(iterations) / timeInSeconds))"
            )
            print("   Languages checked: 2")
        }

        @Test("Performance with 5 languages")
        func performanceWithFiveLanguages() throws {
            let iterations = 5_000
            let testInput = "nieuwsbrief"  // Dutch word
            let translatedString = TestTranslatedString.newsletter
            let clock = ContinuousClock()

            let result = clock.measure {
                withDependencies {
                    $0.languages = [.english, .dutch, .french, .german, .spanish]
                } operation: {
                    for _ in 0..<iterations {
                        var input = Substring(testInput)
                        try? translatedString.parse(&input)
                    }
                }
            }

            let timeInSeconds =
                Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18

            print("📊 PERFORMANCE - 5 Languages:")
            print("   Time: \(result)")
            print("   Time (seconds): \(timeInSeconds)")
            print(
                "   Operations per second: \(String(format: "%.0f", Double(iterations) / timeInSeconds))"
            )
            print("   Languages checked: 5")
        }

        @Test("Performance with 10 languages")
        func performanceWithTenLanguages() throws {
            let iterations = 5_000
            let testInput = "contact"
            let translatedString = TestTranslatedString.contact
            let clock = ContinuousClock()

            let tenLanguages: [Language] = [
                .english, .dutch, .french, .german, .spanish,
                .italian, .portuguese, .russian, .chinese, .japanese,
            ]

            let result = clock.measure {
                withDependencies {
                    $0.languages = Set(tenLanguages)
                } operation: {
                    for _ in 0..<iterations {
                        var input = Substring(testInput)
                        try? translatedString.parse(&input)
                    }
                }
            }

            let timeInSeconds =
                Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18

            print("📊 PERFORMANCE - 10 Languages:")
            print("   Time: \(result)")
            print("   Time (seconds): \(timeInSeconds)")
            print(
                "   Operations per second: \(String(format: "%.0f", Double(iterations) / timeInSeconds))"
            )
            print("   Languages checked: 10")
        }

        @Test("Language count scaling analysis")
        func languageCountScalingAnalysis() throws {
            let iterations = 2_000
            let testInput = "contact"  // Will match first language (English)
            let translatedString = TestTranslatedString.contact

            let languageCounts = [2, 5, 10, 20]
            var results: [(Int, Duration)] = []

            // `Language` (BCP47.LanguageTag) is not CaseIterable. `.supported` is
            // swift-translating's own documented replacement for the former
            // `Language.allCases` (see Translating+Dependencies/LanguagesKey.swift).
            let scalingLanguages = Array(Swift.Set<Language>.supported)

            for languageCount in languageCounts {
                let languages = Array(scalingLanguages.prefix(languageCount))

                let result = ContinuousClock().measure {
                    withDependencies {
                        $0.languages = Set(languages)
                    } operation: {
                        for _ in 0..<iterations {
                            var input = Substring(testInput)
                            try? translatedString.parse(&input)
                        }
                    }
                }

                results.append((languageCount, result))
            }

            print("📊 LANGUAGE COUNT SCALING ANALYSIS:")
            print("   Test: Parsing '\(testInput)' \(iterations) times")
            print("   Current language: English (first to be checked)")

            for (languageCount, duration) in results {
                let timeInSeconds =
                    Double(duration.components.seconds) + Double(duration.components.attoseconds)
                    / 1e18
                let opsPerSecond = Double(iterations) / timeInSeconds

                print(
                    "   \(String(format: "%2d", languageCount)) languages: \(duration) (\(String(format: "%.0f", opsPerSecond)) ops/sec)"
                )
            }

            // Performance should be consistent since we're always matching the first language
            let firstResult =
                Double(results[0].1.components.seconds) + Double(
                    results[0].1.components.attoseconds
                ) / 1e18
            let lastResult =
                Double(results.last!.1.components.seconds) + Double(
                    results.last!.1.components.attoseconds
                )
                / 1e18
            let performanceDegradation = lastResult / firstResult

            print("   Performance degradation: \(String(format: "%.2f", performanceDegradation))x")
            print("   ✅ Should remain fast due to current language fast-path")

            #expect(
                performanceDegradation < 2.0,
                "Performance should not degrade significantly with more languages when matching current language"
            )
        }
    }

    // MARK: - URL Generation Performance Tests

    @Suite(
        "URL Generation Performance",
        .serialized,
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    struct URLGenerationPerformanceTests {

        @Test("String URL generation performance (baseline)")
        func stringURLGenerationPerformance() throws {
            let iterations = 10_000
            let clock = ContinuousClock()

            // Simple string-based router for baseline
            struct SimpleStringRouter: ParserPrinter {
                var body: some URLRouting.Router<TestRoute> {
                    OneOf {
                        URLRouting.Route(.case(TestRoute.home)) {
                            Path { "home" }
                        }
                        URLRouting.Route(.case(TestRoute.about)) {
                            Path { "about-us" }
                        }
                        URLRouting.Route(.case(TestRoute.contact)) {
                            Path { "contact" }
                        }
                    }
                }
            }

            let router = SimpleStringRouter()

            let result = clock.measure {
                for _ in 0..<iterations {
                    _ = router.url(for: .home)
                    _ = router.url(for: .about)
                    _ = router.url(for: .contact)
                }
            }

            let timeInSeconds =
                Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
            let operationsPerSecond = Double(iterations * 3) / timeInSeconds  // 3 URLs per iteration

            print("📊 BASELINE - String URL Generation Performance:")
            print("   Time: \(result)")
            print("   Time (seconds): \(timeInSeconds)")
            print("   URL generations: \(iterations * 3)")
            print("   Operations per second: \(String(format: "%.0f", operationsPerSecond))")
            print(
                "   Average time per URL: \(String(format: "%.2f", timeInSeconds / Double(iterations * 3) * 1_000_000))μs"
            )

            #expect(result < .seconds(1), "String URL generation should be very fast")
        }

        @Test("TranslatedString URL generation performance")
        func translatedStringURLGenerationPerformance() throws {
            let iterations = 10_000
            let router = TestRouter()
            let clock = ContinuousClock()

            let result = clock.measure {
                for _ in 0..<iterations {
                    _ = router.url(for: .home)
                    _ = router.url(for: .about)
                    _ = router.url(for: .contact)
                }
            }

            let timeInSeconds =
                Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
            let operationsPerSecond = Double(iterations * 3) / timeInSeconds

            print("📊 PERFORMANCE - TranslatedString URL Generation:")
            print("   Time: \(result)")
            print("   Time (seconds): \(timeInSeconds)")
            print("   URL generations: \(iterations * 3)")
            print("   Operations per second: \(String(format: "%.0f", operationsPerSecond))")
            print(
                "   Average time per URL: \(String(format: "%.2f", timeInSeconds / Double(iterations * 3) * 1_000_000))μs"
            )

            #expect(
                result < .seconds(2.5),
                "TranslatedString URL generation should be reasonably fast"
            )
        }

        @Test("URL generation in different languages")
        func urlGenerationDifferentLanguagesPerformance() throws {
            let iterations = 5_000
            let router = TestRouter()
            let clock = ContinuousClock()

            // Test English generation
            let englishResult = clock.measure {
                withDependencies {
                    $0.language = .english
                } operation: {
                    for _ in 0..<iterations {
                        _ = router.url(for: .home)
                        _ = router.url(for: .about)
                        _ = router.url(for: .contact)
                    }
                }
            }

            // Test Dutch generation
            let dutchResult = clock.measure {
                withDependencies {
                    $0.language = .dutch
                } operation: {
                    for _ in 0..<iterations {
                        _ = router.url(for: .home)
                        _ = router.url(for: .about)
                        _ = router.url(for: .contact)
                    }
                }
            }

            let englishTimeInSeconds =
                Double(englishResult.components.seconds) + Double(
                    englishResult.components.attoseconds
                )
                / 1e18
            let dutchTimeInSeconds =
                Double(dutchResult.components.seconds) + Double(dutchResult.components.attoseconds)
                / 1e18

            print("📊 URL GENERATION - Language Comparison:")
            print("   English Time: \(englishResult)")
            print(
                "   English Ops/sec: \(String(format: "%.0f", Double(iterations * 3) / englishTimeInSeconds))"
            )
            print("   Dutch Time: \(dutchResult)")
            print(
                "   Dutch Ops/sec: \(String(format: "%.0f", Double(iterations * 3) / dutchTimeInSeconds))"
            )
            print(
                "   Performance difference: \(String(format: "%.2f", dutchTimeInSeconds / englishTimeInSeconds))x"
            )
            print("   ✅ Should be similar performance regardless of language")

            let performanceDifference =
                abs(dutchTimeInSeconds - englishTimeInSeconds)
                / min(dutchTimeInSeconds, englishTimeInSeconds)
            #expect(
                performanceDifference < 0.5,
                "Performance should be similar regardless of current language"
            )
        }
    }

    // MARK: - Router Integration Performance Tests

    @Suite(
        "Router Integration Performance",
        .serialized,
        .dependency(\.language, .english),
        .dependency(\.languages, [.english, .dutch])
    )
    struct RouterIntegrationPerformanceTests {

        @Test("Round-trip performance - Parse and generate URLs")
        func roundTripPerformance() throws {
            let iterations = 5_000
            let router = TestRouter()
            let routes: [TestRoute] = [
                .home, .about, .contact, .privacyPolicy, .generalTerms, .newsletter,
            ]
            let clock = ContinuousClock()

            let result = clock.measure {
                for _ in 0..<iterations {
                    for route in routes {
                        // Generate URL
                        let url = router.url(for: route)
                        // Parse it back
                        _ = try? router.match(url: url)
                    }
                }
            }

            let timeInSeconds =
                Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
            let totalOperations = iterations * routes.count * 2  // Both generate and parse
            let operationsPerSecond = Double(totalOperations) / timeInSeconds

            print("📊 ROUND-TRIP PERFORMANCE:")
            print("   Time: \(result)")
            print("   Time (seconds): \(timeInSeconds)")
            print("   Round-trips: \(iterations * routes.count)")
            print("   Total operations: \(totalOperations)")
            print("   Operations per second: \(String(format: "%.0f", operationsPerSecond))")
            print(
                "   Average round-trip time: \(String(format: "%.2f", timeInSeconds / Double(iterations * routes.count) * 1000))ms"
            )

            #expect(
                result < .seconds(6),
                "Round-trip operations should complete in reasonable time"
            )
        }

        @Test("Error handling performance - Invalid paths")
        func errorHandlingPerformance() throws {
            let iterations = 5_000
            let router = TestRouter()
            let invalidPaths = [
                "/invalid", "/nonexistent", "/fake-path", "/unknown-url", "/missing-route",
            ]
            let clock = ContinuousClock()

            let result = clock.measure {
                for _ in 0..<iterations {
                    for path in invalidPaths {
                        _ = try? router.match(path: path)
                    }
                }
            }

            let timeInSeconds =
                Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
            let totalOperations = iterations * invalidPaths.count
            let operationsPerSecond = Double(totalOperations) / timeInSeconds

            print("📊 ERROR HANDLING PERFORMANCE:")
            print("   Time: \(result)")
            print("   Time (seconds): \(timeInSeconds)")
            print("   Failed parsing attempts: \(totalOperations)")
            print("   Operations per second: \(String(format: "%.0f", operationsPerSecond))")
            print(
                "   Average error handling time: \(String(format: "%.2f", timeInSeconds / Double(totalOperations) * 1_000_000))μs"
            )
            print("   ⚠️  Error handling should be reasonably fast")

            #expect(result < .seconds(5), "Error handling should not be significantly slower")
        }
    }

    // MARK: - Memory Usage Tests

    @Suite(
        "Memory Usage Analysis",
        .serialized
    )
    struct MemoryUsageTests {

        @Test("Memory usage comparison - String vs TranslatedString routers")
        func memoryUsageComparison() throws {
            let initialMemory = Self.getMemoryUsage()

            // Create string-based router
            struct StringRouter: ParserPrinter {
                var body: some URLRouting.Router<TestRoute> {
                    OneOf {
                        URLRouting.Route(.case(TestRoute.home)) { Path { "home" } }
                        URLRouting.Route(.case(TestRoute.about)) { Path { "about-us" } }
                        URLRouting.Route(.case(TestRoute.contact)) { Path { "contact" } }
                        URLRouting.Route(.case(TestRoute.privacyPolicy)) {
                            Path { "privacy-policy" }
                        }
                        URLRouting.Route(.case(TestRoute.generalTerms)) {
                            Path { "general-terms-and-conditions" }
                        }
                        URLRouting.Route(.case(TestRoute.newsletter)) { Path { "newsletter" } }
                    }
                }
            }

            var stringRouter: StringRouter? = StringRouter()
            let stringRouterMemory = Self.getMemoryUsage()

            var translatedRouter: TestRouter? = TestRouter()
            let translatedRouterMemory = Self.getMemoryUsage()

            let stringRouterMemoryIncrease = stringRouterMemory - initialMemory
            let translatedRouterMemoryIncrease = translatedRouterMemory - stringRouterMemory

            print("📊 MEMORY USAGE COMPARISON:")
            print("   Initial memory: \(initialMemory / 1024 / 1024)MB")
            print("   String router memory: \(stringRouterMemory / 1024 / 1024)MB")
            print("   TranslatedString router memory: \(translatedRouterMemory / 1024 / 1024)MB")
            print("   String router increase: \(stringRouterMemoryIncrease / 1024)KB")
            print("   TranslatedString router increase: \(translatedRouterMemoryIncrease / 1024)KB")
            print(
                "   Memory overhead: \(translatedRouterMemoryIncrease - stringRouterMemoryIncrease) bytes"
            )

            if translatedRouterMemoryIncrease > stringRouterMemoryIncrease {
                let overhead = translatedRouterMemoryIncrease - stringRouterMemoryIncrease
                print("   TranslatedString router uses \(overhead) bytes more memory")
            } else {
                print("   ✅ No significant memory overhead detected")
            }

            // Clean up
            stringRouter = nil
            translatedRouter = nil
        }

        // MARK: - Helper Functions

        private static func getMemoryUsage() -> Int64 {
            #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
                var info = mach_task_basic_info_data_t()
                var count = mach_msg_type_number_t(
                    MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<integer_t>.size
                )

                let kerr = withUnsafeMutablePointer(to: &info) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                        task_info(
                            mach_task_self_,
                            task_flavor_t(MACH_TASK_BASIC_INFO),
                            $0,
                            &count
                        )
                    }
                }

                return kerr == KERN_SUCCESS ? Int64(info.resident_size) : 0
            #else
                return 0
            #endif
        }
    }
}

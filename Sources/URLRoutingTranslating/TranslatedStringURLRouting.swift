//
//  TranslatedString+URLRouting.swift
//  coenttb-com-shared
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

import Dependencies
import Foundation
import Translating
import Translating_Dependencies
import URLRouting

/// TranslatedString conforms to `Parser.Protocol` and `Parser.Bidirectional` for use in URL routing.
///
/// ## Usage in Routers
///
/// When using TranslatedString in URL routes, always call `.slug()` to ensure
/// spaces and special characters are converted to URL-friendly format:
///
/// ```swift
/// URLRouting.Route(.case(Route.Website.contact)) {
///     Path { String.contact.slug() }  // Converts "contact us" → "contact-us"
/// }
/// ```
///
/// ## Parsing Behavior
///
/// The parser will match any of the available language translations. For example,
/// if a TranslatedString contains:
/// - English: "privacy-policy"
/// - Dutch: "privacybeleid"
///
/// Both `/en/privacy-policy` and `/nl/privacybeleid` will successfully parse.
///
/// ## Printing Behavior
///
/// When generating URLs, the current language from Dependencies is used to select
/// which translation to output.
extension TranslatedString: @retroactive Parser.`Protocol` {
    public typealias Input = Substring
    public typealias Output = Void
    public typealias Failure = TranslatedStringParsingError

    public func parse(_ input: inout Substring) throws(Failure) -> Output {
        @Dependency(\.language) var currentLanguage
        @Dependency(\.languages) var languages

        // Fast path: Check current language first as it's the most likely match
        let currentTranslation = self[currentLanguage]
        if input.hasPrefix(currentTranslation) {
            input.removeFirst(currentTranslation.count)
            return
        }

        // Check all other available languages
        for language in languages where language != currentLanguage {
            let translation = self[language]

            if input.hasPrefix(translation) {
                input.removeFirst(translation.count)
                return
            }
        }

        // No match found - provide helpful error with all available translations
        let allTranslations = languages.map { self[$0] }
        throw TranslatedStringParsingError(
            input: String(input),
            availableTranslations: Array(Set(allTranslations)).sorted(),
            checkedLanguages: .init(languages)
        )
    }
}

/// Error thrown when a TranslatedString fails to parse a URL path component
public struct TranslatedStringParsingError: Error, CustomDebugStringConvertible {
    let input: String
    let availableTranslations: [String]
    let checkedLanguages: [Language]

    public var debugDescription: String {
        """
        Failed to match '\(input)' against \(checkedLanguages.count) language translations.
        Available translations: \(availableTranslations.joined(separator: ", "))
        """
    }
}

extension TranslatedString: @retroactive Serializer.`Protocol` {
    public typealias Buffer = Substring

    public borrowing func serialize(_ output: Void, into buffer: inout Substring) throws(Failure) {
        @Dependency(\.language) var language

        // Use the translation for the current language (forward-append dual
        // of the retired Parser.Printer prepend implementation).
        // Note: Assumes the TranslatedString is already slugified if needed
        buffer += self[language]
    }
}

extension TranslatedString: @retroactive Coder.`Protocol` {}
extension TranslatedString: @retroactive Parser.Bidirectional {}

// MARK: - Slug Generation

/// Converts every language's translation into a URL-safe slug.
///
/// `swift-translating` used to ship this as `Translated<String>.slug()` (coenttb-era
/// package). It was deleted outright — not renamed — by the "Swift Institute <> coenttb
/// heritage" restructure (`swift-translating` commit `1753ac1a`), which also removed the
/// backing `String.slug()` helper. No migration target exists upstream, so both are
/// reimplemented here as the minimal local equivalent, preserving the original semantics
/// bit-for-bit (verified against the deleted `SlugFunctionalityTests` suite in that
/// commit's parent).
extension TranslatedString {
    /// Returns a copy of this translated string with every language's value slugified.
    ///
    /// The result still conforms to `Parser.Protocol`/`Parser.Bidirectional` (via the conformances above),
    /// so it can be used directly inside a `Path { ... }` builder to generate and match
    /// URL-friendly path segments in any configured language.
    public func slug() -> TranslatedString {
        self.map { $0.slug() }
    }
}

/// Minimal local reimplementation of the coenttb-era `String.slug()` helper, deleted
/// upstream from `swift-translating` without a replacement (see `TranslatedString.slug()`
/// above). `fileprivate` (rather than `private`) because both this file's original
/// `debugURLPaths` call site and the new `TranslatedString.slug()` above call it from
/// within `extension TranslatedString`, not `extension String` — `private` would not be
/// visible across that type boundary even in the same file.
extension String {
    fileprivate func slug() -> String {
        self
            .lowercased()
            .replacingOccurrences(of: "[\\W]+", with: "-", options: .regularExpression)
            .replacingOccurrences(of: "^-|-$", with: "", options: .regularExpression)
    }
}

// MARK: - Debugging Helpers

extension TranslatedString {
    /// Returns a debug description showing all translations for this string
    ///
    /// Example output:
    /// ```
    /// TranslatedString {
    ///   english: 'general-terms-and-conditions',
    ///   dutch: 'algemene-voorwaarden'
    /// }
    /// ```
    public var debugTranslations: String {
        @Dependency(\.languages) var languages

        let translations = languages.compactMap { language -> String? in
            let translation = self[language]
            return "\(language): '\(translation)'"
        }

        return "TranslatedString { \(translations.joined(separator: ", ")) }"
    }

    /// Returns a debug description showing how this string would appear in URLs
    /// for each language (useful for debugging routing issues)
    public var debugURLPaths: String {
        @Dependency(\.languages) var languages

        let paths = languages.compactMap { language -> String? in
            let translation = self[language]
            let slugified = translation.slug()
            if translation == slugified {
                return "/\(language.value)/\(translation)"
            } else {
                return "/\(language.value)/\(translation) → /\(language.value)/\(slugified)"
            }
        }

        return "URL paths: \(paths.joined(separator: ", "))"
    }
}

// MARK: - Performance Optimization

/// Cache for storing parsed TranslatedString results to avoid repeated dependency lookups
/// Note: This is an advanced optimization. Only use if profiling shows parsing performance issues.
private actor TranslatedStringParsingCache {
    private var cache: [CacheKey: Set<String>] = [:]

    struct CacheKey: Hashable {
        let translatedStringID: ObjectIdentifier
        let languagesHash: Int
    }

    func getCachedTranslations(for translatedString: TranslatedString, languages: [Language])
        -> Set<
            String
        >?
    {
        let key = CacheKey(
            translatedStringID: ObjectIdentifier(translatedString as AnyObject),
            languagesHash: languages.hashValue
        )
        return cache[key]
    }

    func setCachedTranslations(
        _ translations: Set<String>,
        for translatedString: TranslatedString,
        languages: [Language]
    ) {
        let key = CacheKey(
            translatedStringID: ObjectIdentifier(translatedString as AnyObject),
            languagesHash: languages.hashValue
        )
        cache[key] = translations
    }

    func clear() {
        cache.removeAll()
    }
}

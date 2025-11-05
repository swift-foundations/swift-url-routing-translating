//
//  TestTranslatedString.swift
//  URLRoutingTranslating Tests
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

import Translating
import URLRoutingTranslating

// MARK: - Test TranslatedStrings

enum TestTranslatedString {
    static let home: TranslatedString = [
        .english: "home",
        .dutch: "thuis",
    ]

    static let about: TranslatedString = [
        .english: "about us",
        .dutch: "over ons",
    ]

    static let contact: TranslatedString = [
        .english: "contact",
        .dutch: "contact",
    ]

    static let privacyPolicy: TranslatedString = [
        .english: "privacy policy",
        .dutch: "privacybeleid",
    ]

    static let generalTerms: TranslatedString = [
        .english: "general terms and conditions",
        .dutch: "algemene voorwaarden",
    ]

    static let newsletter: TranslatedString = [
        .english: "newsletter",
        .dutch: "nieuwsbrief",
    ]

    // MARK: - Multi-language Test Strings

    static let multiLanguage: TranslatedString = [
        .english: "multi language test",
        .dutch: "meertalige test",
        .german: "mehrsprachiger test",
    ]

    static let identical: TranslatedString = [
        .english: "same",
        .dutch: "same",
    ]

    static let performanceTest: TranslatedString = [
        .english: "test",
        .dutch: "test",
    ]
}

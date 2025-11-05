//
//  TestRouter.swift
//  URLRoutingTranslating Tests
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

import Translating
import URLRouting
import URLRoutingTranslating

// MARK: - Test Route

enum TestRoute: Equatable, Sendable {
    case home
    case about
    case contact
    case privacyPolicy
    case generalTerms
    case newsletter
}

// MARK: - Test Router

struct TestRouter: ParserPrinter {
    var body: some URLRouting.Router<TestRoute> {
        OneOf {
            URLRouting.Route(.case(TestRoute.home)) {
                Path { TestTranslatedString.home.slug() }
            }

            URLRouting.Route(.case(TestRoute.about)) {
                Path { TestTranslatedString.about.slug() }
            }

            URLRouting.Route(.case(TestRoute.contact)) {
                Path { TestTranslatedString.contact.slug() }
            }

            URLRouting.Route(.case(TestRoute.privacyPolicy)) {
                Path { TestTranslatedString.privacyPolicy.slug() }
            }

            URLRouting.Route(.case(TestRoute.generalTerms)) {
                Path { TestTranslatedString.generalTerms.slug() }
            }

            URLRouting.Route(.case(TestRoute.newsletter)) {
                Path { TestTranslatedString.newsletter.slug() }
            }
        }
    }
}

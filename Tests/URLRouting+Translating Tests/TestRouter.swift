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

@Cases
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
            URLRouting.Route(.case(TestRoute.cases.home)) {
                Path { TestTranslatedString.home.slug() }
            }

            URLRouting.Route(.case(TestRoute.cases.about)) {
                Path { TestTranslatedString.about.slug() }
            }

            URLRouting.Route(.case(TestRoute.cases.contact)) {
                Path { TestTranslatedString.contact.slug() }
            }

            URLRouting.Route(.case(TestRoute.cases.privacyPolicy)) {
                Path { TestTranslatedString.privacyPolicy.slug() }
            }

            URLRouting.Route(.case(TestRoute.cases.generalTerms)) {
                Path { TestTranslatedString.generalTerms.slug() }
            }

            URLRouting.Route(.case(TestRoute.cases.newsletter)) {
                Path { TestTranslatedString.newsletter.slug() }
            }
        }
    }
}

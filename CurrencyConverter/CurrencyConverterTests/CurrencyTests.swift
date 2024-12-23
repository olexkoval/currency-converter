//
//  CurrencyTests.swift
//  CurrencyConverterTests
//
//  Created by Oleksandr Koval on 23.12.2024.
//

import XCTest
@testable import CurrencyConverter

class CurrencyTests: XCTestCase {

    func testCurrencyInitializationWithValidISOCode() throws {
        let validISOCode = "USD"

        let currency = try Currency(currencyISOCode: validISOCode)

        XCTAssertEqual(currency.currencyISOCode, validISOCode, "Currency should be initialized with a valid ISO code.")
    }

    func testCurrencyInitializationWithLowercaseISOCode() throws {
        let lowercaseISOCode = "usd"

        let currency = try Currency(currencyISOCode: lowercaseISOCode)

        XCTAssertEqual(currency.currencyISOCode, "USD", "Currency ISO code should be normalized to uppercase.")
    }

    func testCurrencyInitializationWithInvalidISOCodeThrowsError() {
        let invalidISOCode = "XYZ"

        XCTAssertThrowsError(try Currency(currencyISOCode: invalidISOCode)) { error in
            XCTAssertEqual(error as? CurrencyError, CurrencyError.invalidCurrencyISOCode, "Expected CurrencyError.invalidCurrencyISOCode for an unsupported ISO code.")
        }
    }

    func testCurrencyDescription() throws {
        let validISOCode = "EUR"
        let currency = try Currency(currencyISOCode: validISOCode)

        XCTAssertEqual(currency.description, validISOCode, "Currency description should match the ISO code.")
    }

    func testPredefinedCurrencies() {
        let usd = Currency.usd
        let eur = Currency.eur

        XCTAssertEqual(usd.currencyISOCode, "USD", "Predefined USD currency should have ISO code 'USD'.")
        XCTAssertEqual(eur.currencyISOCode, "EUR", "Predefined EUR currency should have ISO code 'EUR'.")
    }

    func testSupportedCurrencyISOCodes() {
        let allCodes = Currency.allCurrencyISOCodes

        XCTAssertTrue(allCodes.contains("USD"), "USD should be part of the supported or foundation ISO codes.")
        XCTAssertTrue(allCodes.contains("EUR"), "EUR should be part of the supported or foundation ISO codes.")
    }

    func testInvalidCurrencyErrorDescription() {
        let error = CurrencyError.invalidCurrencyISOCode

        XCTAssertEqual(error.localizedDescription, "Invalid Currency ISO Code was provided", "Error description should match the defined localized error message.")
    }
}

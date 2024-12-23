//
//  NetworkingTests.swift
//  CurrencyConverterTests
//
//  Created by Oleksandr Koval on 23.12.2024.
//

import XCTest
@testable import CurrencyConverter
import Combine

class NetworkingTests: XCTestCase {
    func testCurrencyConversionRequestIsValid() throws {
        let sourceCurrency = try Currency(currencyISOCode: "USD")
        let targetCurrency = try Currency(currencyISOCode: "EUR")
        let amount = try Amount(value: 100)
        let request = CurrencyConversionRequest(sourceCurrency: sourceCurrency, targetCurrency: targetCurrency, amount: amount)

        XCTAssertTrue(request.isValid, "CurrencyConversionRequest should be valid when amount is greater than zero.")
    }

    func testCurrencyConversionRequestIsInvalid() throws {
        let sourceCurrency = try Currency(currencyISOCode: "USD")
        let targetCurrency = try Currency(currencyISOCode: "EUR")
        let amount = try Amount(value: 0)
        let request = CurrencyConversionRequest(sourceCurrency: sourceCurrency, targetCurrency: targetCurrency, amount: amount)

        XCTAssertFalse(request.isValid, "CurrencyConversionRequest should be invalid when amount is zero.")
    }

    func testCurrencyConversionNetworkResponseDecoding() throws {
        let json = """
        {
            "amount": "100.5",
            "currency": "USD"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(CurrencyConversionNetworkResponse.self, from: json)

        XCTAssertEqual(response.amount, "100.5", "Amount should match the value from JSON.")
        XCTAssertEqual(response.currency, "USD", "Currency should match the value from JSON.")
    }

    func testCurrencyConversionNetworkErrorResponseDecoding() throws {
        let json = """
        {
            "error": "Invalid Request",
            "error_description": "The source currency is not supported."
        }
        """.data(using: .utf8)!

        let errorResponse = try JSONDecoder().decode(CurrencyConversionNetworkErrorResponse.self, from: json)

        XCTAssertEqual(errorResponse.errorTitle, "Invalid Request", "Error title should match the value from JSON.")
        XCTAssertEqual(errorResponse.errorDescription, "The source currency is not supported.", "Error description should match the value from JSON.")
    }

    func testCurrencyConversionResponseInitialization() throws {
        let networkResponse = CurrencyConversionNetworkResponse(amount: "150.25", currency: "EUR")

        let response = try CurrencyConversionResponse(networkResponse: networkResponse)

        XCTAssertEqual(response.amount.value, 150.25, "Amount value should match the parsed value.")
        XCTAssertEqual(response.currency.currencyISOCode, "EUR", "Currency ISO code should match the parsed value.")
    }

    func testCurrencyConversionResponseInitializationFailsForInvalidAmount() {
        let networkResponse = CurrencyConversionNetworkResponse(amount: "invalid", currency: "EUR")

        XCTAssertThrowsError(try CurrencyConversionResponse(networkResponse: networkResponse)) { error in
            XCTAssertEqual(error as? AmountError, AmountError.nonPositiveValueNotAllowed, "Expected AmountError.nonPositiveValueNotAllowed for invalid amount value.")
        }
    }

    func testCurrencyConversionNetworkErrorDescription() {
        let error = CurrencyConversionNetworkError.serverResponseError("Something went wrong")

        XCTAssertEqual(error.localizedDescription, "Server Error\nSomething went wrong", "Error description should match the defined format.")
    }

    func testCurrencyConversionNetworkManagerInvalidURL() {
        let manager = CurrencyConversionNetworkManagerImpl()
        let sourceCurrency = try! Currency(currencyISOCode: "USD")
        let targetCurrency = try! Currency(currencyISOCode: "EUR")
        let request = CurrencyConversionRequest(sourceCurrency: sourceCurrency, targetCurrency: targetCurrency, amount: try! Amount(value: 100))

        let url = CurrencyConversionNetworkManagerImpl.url(from: request)

        XCTAssertNotNil(url, "The URL should be generated correctly for a valid request.")
    }
}

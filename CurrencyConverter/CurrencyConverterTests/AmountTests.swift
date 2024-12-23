//
//  AmountTests.swift
//  CurrencyConverterTests
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import XCTest
@testable import CurrencyConverter

class AmountTests: XCTestCase {

    func testAmountInitializationWithPositiveValue() throws {
        let positiveValue = 10.0

        let amount = try Amount(value: positiveValue)

        XCTAssertEqual(amount.value, positiveValue, "Amount should be initialized with the given positive value.")
    }

    func testAmountInitializationWithZero() throws {
        let zeroValue = 0.0

        let amount = try Amount(value: zeroValue)

        XCTAssertEqual(amount.value, zeroValue, "Amount should be initialized with zero.")
    }

    func testAmountInitializationWithNegativeValueThrowsError() {
        let negativeValue = -5.0

        XCTAssertThrowsError(try Amount(value: negativeValue)) { error in
            XCTAssertEqual(error as? AmountError, AmountError.nonPositiveValueNotAllowed, "Expected AmountError.nonPositiveValueNotAllowed for negative values.")
        }
    }

    func testAmountZeroConstant() {
        let zeroAmount = Amount.zero

        XCTAssertEqual(zeroAmount.value, 0.0, "Amount.zero should have a value of 0.0.")
    }

    func testAmountDescription() throws {
        let value = 42.0
        let amount = try Amount(value: value)

        XCTAssertEqual(amount.description, "42.0", "Amount description should match the string representation of its value.")
    }

    func testAmountErrorDescription() {
        let error = AmountError.nonPositiveValueNotAllowed

        XCTAssertEqual(error.localizedDescription, "Invalid amount value was provided", "Error description should match the defined localized error message.")
    }
}

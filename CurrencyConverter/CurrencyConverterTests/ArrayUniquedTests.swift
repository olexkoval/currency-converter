//
//  ArrayUniquedTests.swift
//  CurrencyConverterTests
//
//  Created by Oleksandr Koval on 23.12.2024.
//

import XCTest
@testable import CurrencyConverter

class ArrayUniquedTests: XCTestCase {

    func testUniquedWithUniqueElements() {
        let array = [1, 2, 3, 4, 5]

        let result = array.uniqued()

        XCTAssertEqual(result, array, "The result should match the original array when all elements are unique.")
    }

    func testUniquedWithDuplicateElements() {
        let array = [1, 2, 2, 3, 3, 3, 4]

        let result = array.uniqued()

        XCTAssertEqual(result, [1, 2, 3, 4], "The result should contain only the first occurrence of each element in the array.")
    }

    func testUniquedWithEmptyArray() {
        let array: [Int] = []

        let result = array.uniqued()

        XCTAssertEqual(result, [], "The result should be an empty array when the input is empty.")
    }

    func testUniquedWithStrings() {
        let array = ["apple", "banana", "apple", "orange", "banana"]

        let result = array.uniqued()

        XCTAssertEqual(result, ["apple", "banana", "orange"], "The result should contain only the first occurrence of each string in the array.")
    }

    func testUniquedWithCustomObjects() {

        let array: [Currency] =  [.usd, .eur, .usd]

        let result = array.uniqued()

        XCTAssertEqual(result, [.usd, .eur], "The result should contain only the first occurrence of each custom object in the array.")
    }
}

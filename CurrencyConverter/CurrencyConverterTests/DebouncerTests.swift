//
//  DebouncerTests.swift
//  CurrencyConverterTests
//
//  Created by Oleksandr Koval on 23.12.2024.
//

import XCTest
@testable import CurrencyConverter

class DebouncerTests: XCTestCase {

    func testDebounceExecutesActionAfterDelay() {
        let expectation = self.expectation(description: "Debounced action executed after delay")
        let debouncer = Debouncer(delay: 0.2)
        var actionExecuted = false

        debouncer.debounce {
            actionExecuted = true
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3) { error in
            XCTAssertNil(error, "The debounced action was not executed in time.")
            XCTAssertTrue(actionExecuted, "The action should have been executed after the delay.")
        }
    }

    func testDebounceCancelsPreviousAction() {
        let expectation = self.expectation(description: "Only the latest debounced action is executed")
        let debouncer = Debouncer(delay: 0.2)
        var actionExecutionCount = 0

        debouncer.debounce {
            actionExecutionCount += 1
        }

        debouncer.debounce {
            actionExecutionCount += 1
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3) { error in
            XCTAssertNil(error, "The latest debounced action was not executed in time.")
            XCTAssertEqual(actionExecutionCount, 1, "Only the latest action should have been executed.")
        }
    }

    func testDebounceWithNoActionDoesNotCrash() {
        let debouncer = Debouncer(delay: 0.2)
        
        debouncer.debounce(action: {})
    }

    func testDebounceOnCustomQueue() {
        let expectation = self.expectation(description: "Debounced action executed on custom queue")
        let customQueue = DispatchQueue(label: "com.example.customQueue")
        let debouncer = Debouncer(delay: 0.2, queue: customQueue)
        let key = DispatchSpecificKey<Void>()
        customQueue.setSpecific(key: key, value: ())

        debouncer.debounce {
            if DispatchQueue.getSpecific(key: key) != nil {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3) { error in
            XCTAssertNil(error, "The debounced action was not executed on the custom queue.")
        }
    }
}

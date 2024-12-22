//
//  Amount.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

enum AmountError: Error {
    case nonPositiveValueNotAllowed
}

extension AmountError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .nonPositiveValueNotAllowed:
            return "Invalid amount value was provided"
        }
    }
}

struct Amount {    
    let value: Double
    
    static let zero: Amount = try! Amount(value: 0)
    
    init(value: Double) throws {
        guard value >= 0 else {
            throw AmountError.nonPositiveValueNotAllowed
        }
        
        self.value = value
    }
}

extension Amount: CustomStringConvertible {
    var description: String { String(value) }
}

//
//  Amount.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

struct Amount {    
    let value: Double
    
    enum AmountError: Error {
        case nonPositiveValueNotAllowed
    }
    
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

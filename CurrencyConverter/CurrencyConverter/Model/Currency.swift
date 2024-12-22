//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

struct Currency {
    
    private static let allISOCurrencyCodes = 
    if #available(iOS 16, *) {
        Set(Locale.commonISOCurrencyCodes)
    } else {
        Set(Locale.isoCurrencyCodes)
    }
    
    enum CurrencyError: Error {
        case invalidISOCurrencyCode
    }
    
    static let usd: Currency = try! Currency(isoCurrencyCode: "USD")
    static let eur: Currency = try! Currency(isoCurrencyCode: "EUR")
    
    let isoCurrencyCode: String
    
    init(isoCurrencyCode: String) throws {
        let uppercasedISOCode = isoCurrencyCode.uppercased()
        
        guard Currency.allISOCurrencyCodes.contains(uppercasedISOCode) else {
            throw CurrencyError.invalidISOCurrencyCode
        }
        
        self.isoCurrencyCode = uppercasedISOCode
    }
}

extension Currency: CustomStringConvertible {
    var description: String { isoCurrencyCode }
}

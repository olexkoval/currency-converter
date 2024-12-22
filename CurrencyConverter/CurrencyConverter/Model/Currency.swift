//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

struct Currency: Hashable {
    
    private static let allCurrencyISOCodes =
    if #available(iOS 16, *) {
        Set(Locale.commonISOCurrencyCodes)
    } else {
        Set(Locale.isoCurrencyCodes)
    }
    
    enum CurrencyError: Error {
        case invalidCurrencyISOCode
    }
    
    static let usd: Currency = try! Currency(currencyISOCode: "USD")
    static let eur: Currency = try! Currency(currencyISOCode: "EUR")
    
    let currencyISOCode: String
    
    init(currencyISOCode: String) throws {
        let uppercasedISOCode = currencyISOCode.uppercased()
        
        guard Currency.allCurrencyISOCodes.contains(uppercasedISOCode) else {
            throw CurrencyError.invalidCurrencyISOCode
        }
        
        self.currencyISOCode = uppercasedISOCode
    }
}

extension Currency: CustomStringConvertible {
    var description: String { currencyISOCode }
}

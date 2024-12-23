//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

enum CurrencyError: Error {
    case invalidCurrencyISOCode
}

extension CurrencyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCurrencyISOCode:
            return "Invalid Currency ISO Code was provided"
        }
    }
}

struct Currency: Hashable {
    
    static let supportedCurrencyISOCodes: [String] = [
//        Please specify here the list of supported Currency ISO Codes
//        otherwise Foundation Currency ISO Codes will be used
//        Please do not forget to reinstall the application after changing this list as CoreData can work incorrecly
//
//        "Usd", "eur",...
    ]
    
    static let foundationCurrencyISOCodes =
    if #available(iOS 16, *) {
        Locale.commonISOCurrencyCodes
    } else {
        Locale.isoCurrencyCodes
    }
    
    static let allCurrencyISOCodes = supportedCurrencyISOCodes.isEmpty ?
    foundationCurrencyISOCodes : supportedCurrencyISOCodes
    
    private static let allCurrencyISOCodesSet = Set(allCurrencyISOCodes)
    
    static let usd: Currency = try! Currency(currencyISOCode: "USD")
    static let eur: Currency = try! Currency(currencyISOCode: "EUR")
    
    let currencyISOCode: String
    
    init(currencyISOCode: String) throws {
        let uppercasedISOCode = currencyISOCode.uppercased()
        
        guard Currency.allCurrencyISOCodesSet.contains(uppercasedISOCode) else {
            throw CurrencyError.invalidCurrencyISOCode
        }
        
        self.currencyISOCode = uppercasedISOCode
    }
}

extension Currency: CustomStringConvertible {
    var description: String { currencyISOCode }
}

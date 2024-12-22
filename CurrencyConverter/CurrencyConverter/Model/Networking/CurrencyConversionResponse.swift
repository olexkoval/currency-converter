//
//  CurrencyConversionResponse.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

struct CurrencyConversionNetworkResponse: Decodable {
    let amount: String
    let currency: String
}

struct CurrencyConversionNetworkErrorResponse {
    
    enum CurrencyConversionNetworkError: Error {
        case serverResponseError
    }
    
    let errorTitle: String
    let errorDescription: String
    
    var error: Error {
        CurrencyConversionNetworkError.serverResponseError
    }
}

extension CurrencyConversionNetworkErrorResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case error
        case error_description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        errorTitle = try container.decode(String.self, forKey: .error)
        errorDescription = try container.decode(String.self, forKey: .error_description)
    }
}

struct CurrencyConversionResponse {
    let amount: Amount
    let currency: Currency
    
    enum CurrencyConversionResponseError: Error {
        case invalidResponseAmountValue
    }
    
    init(networkResponse: CurrencyConversionNetworkResponse) throws {
        guard let amountValue = Double(networkResponse.amount) else {
            throw CurrencyConversionResponseError.invalidResponseAmountValue
        }
        self.amount = try Amount(value: amountValue)
        self.currency = try Currency(isoCurrencyCode: networkResponse.currency)
    }
}

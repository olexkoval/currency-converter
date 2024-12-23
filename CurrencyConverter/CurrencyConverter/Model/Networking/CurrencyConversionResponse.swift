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

enum CurrencyConversionNetworkError: Error, Equatable {
    case serverResponseError(String)
    case invalidServerResponse(String)
}

extension CurrencyConversionNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverResponseError(let errorInfo):
            return "Server Error\n\(errorInfo)"
        case .invalidServerResponse(let error):
            return "Server response is invalid\n\(error)"
        }
    }
}

struct CurrencyConversionNetworkErrorResponse {
    let errorTitle: String
    let errorDescription: String
    
    var error: Error {
        CurrencyConversionNetworkError.serverResponseError("\(errorTitle)\n\(errorDescription)")
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
    
    init(networkResponse: CurrencyConversionNetworkResponse) throws {
        do {
            guard let amountValue = Double(networkResponse.amount) else {
                throw AmountError.nonPositiveValueNotAllowed
            }
            self.amount = try Amount(value: amountValue)
            self.currency = try Currency(currencyISOCode: networkResponse.currency)
        }
        catch {
            throw CurrencyConversionNetworkError.invalidServerResponse(error.localizedDescription)
        }
    }
}

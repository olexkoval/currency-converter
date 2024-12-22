//
//  CurrencyConversionNetworkManager.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation
import Combine

protocol CurrencyConversionNetworkManager {
    func getCurrencyConversion(from request: CurrencyConversionRequest) -> AnyPublisher<CurrencyConversionResponse, Error>
}

struct CurrencyConversionNetworkManagerImpl {
    enum NetworkingError: Error {
        case invalidURL
    }
    
    private static func url(from request: CurrencyConversionRequest) -> URL? {
        URL(string: "http://api.evp.lt/currency/commercial/exchange/\(request.amount)-\(request.sourceCurrency)/\(request.targetCurrency)/latest")
    }
}

extension CurrencyConversionNetworkManagerImpl: CurrencyConversionNetworkManager {
    func getCurrencyConversion(from request: CurrencyConversionRequest) ->  AnyPublisher<CurrencyConversionResponse, Error> {
        
        guard let url = Self.url(from: request) else {
            return Fail(error: NetworkingError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                do {
                    let networkResponse = try JSONDecoder().decode(CurrencyConversionNetworkResponse.self, from: data)
                    do {
                        return try CurrencyConversionResponse(networkResponse: networkResponse)
                    }
                    catch {
                        throw error
                    }
                }
                catch {
                    let errorResponse = try JSONDecoder().decode(CurrencyConversionNetworkErrorResponse.self, from: data)
                    throw errorResponse.error
                }
            }
            .eraseToAnyPublisher()
    }
}

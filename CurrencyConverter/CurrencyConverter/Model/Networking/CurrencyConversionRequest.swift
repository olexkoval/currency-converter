//
//  CurrencyConversionRequest.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

struct CurrencyConversionRequest {
    let sourceCurrency: Currency
    let targetCurrency: Currency
    let amount: Amount
}

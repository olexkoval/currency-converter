//
//  CurrencyConverterViewModelData.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

protocol CurrencyConverterViewModelData {
    var sourceCurrency: String { get }
    var sourceAmount: String { get }
    var targetCurrency: String { get }
    var targetAmount: String { get }
}

struct CurrencyConverterViewModelDataImpl {
    let source: Currency
    let inputAmount: Amount
    let target: Currency
    let outputAmount: Amount
}

extension CurrencyConverterViewModelDataImpl: CurrencyConverterViewModelData {
    var sourceCurrency: String { "\(source)" }
    var sourceAmount: String { "\(inputAmount)" }
    var targetCurrency: String { "\(target)" }
    var targetAmount: String { "\(outputAmount)" }
}

//
//  CurrencyPickerViewModel.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

protocol CurrencyPickerViewModel: AnyObject {
    var recents: [String] { get }
    var all: [String] { get }
    
    var filter: String { get set }
    var isFiltering: Bool { get }
}

final class CurrencyPickerViewModelImpl {
    private let allCurrencyISOCodes: [String]
    private let recentCurrencies: [String]
    
    private static let allISOCurrencyCodes =
    if #available(iOS 16, *) {
        Locale.commonISOCurrencyCodes
    } else {
        Locale.isoCurrencyCodes
    }
    
    var filter = ""
    
    init(recentCurrenciesManager: RecentCurrenciesManager,
         allCurrencyISOCodes: [String] = CurrencyPickerViewModelImpl.allISOCurrencyCodes)
    {
        self.allCurrencyISOCodes = allCurrencyISOCodes
        self.recentCurrencies = recentCurrenciesManager.recentCurrencies(maxCount: 10).map(\.isoCurrencyCode)
    }
}

extension CurrencyPickerViewModelImpl: CurrencyPickerViewModel {
    
    var isFiltering: Bool {
        !filter.isEmpty
    }
    
    var recents: [String] {
        guard !filter.isEmpty else { return recentCurrencies }
        return recentCurrencies.filter { $0.range(of: filter, options: .caseInsensitive) != nil }
    }
    
    var all: [String] {
        guard !filter.isEmpty else { return allCurrencyISOCodes }
        return allCurrencyISOCodes.filter { $0.range(of: filter, options: .caseInsensitive) != nil }
    }
}

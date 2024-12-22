//
//  RecentCurrenciesManager.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

protocol RecentCurrenciesManager {
    var lastUsedSourceCurrency: Currency? { get }
    var lastUsedTargetCurrency: Currency? { get }
    func recentCurrencies(maxCount: UInt) -> [Currency]
    func addRecentCurrency(_ currency: Currency, isSource: Bool)
}

final class RecentCurrenciesManagerImpl {
    
}

extension RecentCurrenciesManagerImpl: RecentCurrenciesManager {
    var lastUsedSourceCurrency: Currency? {
        nil
    }
    
    var lastUsedTargetCurrency: Currency? {
        nil
    }
    
    func recentCurrencies(maxCount: UInt) -> [Currency] {
        []
    }
    
    func addRecentCurrency(_ currency: Currency, isSource: Bool) {
        
    }
}

//
//  RecentCurrenciesManager.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation
import CoreData

protocol RecentCurrenciesManager {
    var lastUsedSourceCurrency: Currency? { get }
    var lastUsedTargetCurrency: Currency? { get }
    func recentCurrencies(maxCount: UInt) -> [Currency]
    func addRecentCurrency(_ currency: Currency, isSource: Bool)
}

final class RecentCurrenciesManagerImpl {
    private let context: NSManagedObjectContext
    private let stack: CoreDataStack
    
    init(stack: CoreDataStack) {
        self.stack = stack
        self.context = stack.context
    }
}

private extension RecentCurrenciesManagerImpl {
        
    func fetchLastUsedCurrency(isSource: Bool) -> Currency? {
        let fetchRequest: NSFetchRequest<RecentCurrencyMO> = RecentCurrencyMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isSource == %@", NSNumber(value: isSource))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            if let result = try context.fetch(fetchRequest).first {
                return try Currency(currencyISOCode: result.currencyISOCode)
            }
        } catch {
            assertionFailure("Failed to fetch last used currency: \(error)")
        }
        return nil
    }
    
    func deleteCurrencyIfExists(isoCode: String, isSource: Bool) {
        let fetchRequest: NSFetchRequest<RecentCurrencyMO> = RecentCurrencyMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "currencyISOCode == %@ AND isSource == %@", isoCode, NSNumber(value: isSource))
        
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
        } catch {
            assertionFailure("Failed to delete duplicate currency: \(error)")
        }
    }
}

extension RecentCurrenciesManagerImpl: RecentCurrenciesManager {
    var lastUsedSourceCurrency: Currency? {
        return fetchLastUsedCurrency(isSource: true)
    }
    
    var lastUsedTargetCurrency: Currency? {
        return fetchLastUsedCurrency(isSource: false)
    }
    
    func recentCurrencies(maxCount: UInt) -> [Currency] {
        let fetchRequest: NSFetchRequest<RecentCurrencyMO> = RecentCurrencyMO.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchRequest.fetchLimit = Int(maxCount)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { try! Currency(currencyISOCode: $0.currencyISOCode) }.uniqued()
        } catch {
            assertionFailure("Failed to fetch recentCurrencies")
            return []
        }
    }
    
    func addRecentCurrency(_ currency: Currency, isSource: Bool) {
        deleteCurrencyIfExists(isoCode: currency.currencyISOCode, isSource: isSource)
        
        let recentCurrency = RecentCurrencyMO(context: context)
        recentCurrency.currencyISOCode = currency.currencyISOCode
        recentCurrency.isSource = isSource
        recentCurrency.creationDate = Date()
        
        stack.saveContext()
    }
}

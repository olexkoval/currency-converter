//
//  RecentCurrencyMO+CoreDataProperties.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//
//

import Foundation
import CoreData


extension RecentCurrencyMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecentCurrencyMO> {
        return NSFetchRequest<RecentCurrencyMO>(entityName: "RecentCurrencyMO")
    }

    @NSManaged public var currencyISOCode: String
    @NSManaged public var creationDate: Date
    @NSManaged public var isSource: Bool

}

extension RecentCurrencyMO : Identifiable {

}

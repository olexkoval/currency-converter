//
//  CoreDataStack.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import CoreData
import Foundation

final class CoreDataStack {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CurrencyConverter")
        container.loadPersistentStores { _, error in
            if let error = error {
                assertionFailure("Failed to initialize CoreDataStack")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                assertionFailure("Failed to save context \(error)")
            }
        }
    }
}

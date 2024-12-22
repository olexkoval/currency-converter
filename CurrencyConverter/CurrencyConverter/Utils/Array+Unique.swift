//
//  Array+Unique.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

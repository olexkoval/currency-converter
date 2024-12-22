//
//  Debouncer.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation

class Debouncer {
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    private let delay: TimeInterval

    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()

        workItem = DispatchWorkItem(block: action)

        if let workItem = workItem {
            queue.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
}

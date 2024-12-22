//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation
import Combine

enum CurrencyConverterLoadingState {
  case loading
  case finishedLoading
  case error(Error)
}

protocol CurrencyConverterViewModel: AnyObject {
    func sourceCurrencyChanged(_ sourceCurrencyISOCode: String)
    func targetCurrencyChanged(_ targetCurrencyISOCode: String)
    func amountChanged(_ amount: String)
    func isValidAmount(_ amount: String) -> Bool
    
    func onAppear()
    
    var currencyConverterPublisher: Published<CurrencyConverterViewModelData>.Publisher { get }
    var loadingStatePublisher: Published<CurrencyConverterLoadingState>.Publisher { get }
}

final class CurrencyConverterViewModelImpl {
    private let recentCurrenciesManager: RecentCurrenciesManager
    private let networkManager: CurrencyConversionNetworkManager
    
    @Published private(set) var currentData: CurrencyConverterViewModelData
    @Published private(set) var state: CurrencyConverterLoadingState = .finishedLoading
    
    private var bindings = Set<AnyCancellable>()
    
    init(recentCurrenciesManager: RecentCurrenciesManager, 
         networkManager: CurrencyConversionNetworkManager)
    {
        self.recentCurrenciesManager = recentCurrenciesManager
        self.networkManager = networkManager
        
        currentData = CurrencyConverterViewModelDataImpl(source: recentCurrenciesManager.lastUsedSourceCurrency ?? .usd,
                                                         inputAmount: .zero,
                                                         target: recentCurrenciesManager.lastUsedTargetCurrency ?? .eur,
                                                         outputAmount: .zero)
    }
}

extension CurrencyConverterViewModelImpl: CurrencyConverterViewModel {
    func onAppear() {
        currentData = currentData
    }
    
    func sourceCurrencyChanged(_ sourceCurrencyISOCode: String) {
        do {
            let sourceCurrency = try Currency(isoCurrencyCode: sourceCurrencyISOCode)
            
            guard let cd = currentData as? CurrencyConverterViewModelDataImpl else {
                assertionFailure("Failed to cast currentData to CurrencyConverterViewModelDataImpl")
                return
            }
            
            currentData = CurrencyConverterViewModelDataImpl(source: sourceCurrency,
                                                             inputAmount: cd.inputAmount,
                                                             target: cd.target,
                                                             outputAmount: cd.outputAmount)
            
            recentCurrenciesManager.addRecentCurrency(sourceCurrency, isSource: true)
            
            update()
            
        } catch {
            assertionFailure("Failed to change source currency - Invalid \(error)")
        }
    }
    
    func targetCurrencyChanged(_ targetCurrencyISOCode: String) {
        do {
            let targetCurrency = try Currency(isoCurrencyCode: targetCurrencyISOCode)
            
            guard let cd = currentData as? CurrencyConverterViewModelDataImpl else {
                assertionFailure("Failed to cast currentData to CurrencyConverterViewModelDataImpl")
                return
            }
            
            currentData = CurrencyConverterViewModelDataImpl(source: cd.source,
                                                             inputAmount: cd.inputAmount,
                                                             target: targetCurrency,
                                                             outputAmount: cd.outputAmount)
            
            recentCurrenciesManager.addRecentCurrency(targetCurrency, isSource: false)
            
            update()
            
        } catch {
            assertionFailure("Failed to change target currency - Invalid \(error)")
        }
    }
    
    func amountChanged(_ amount: String) {
        guard let value = Double(amount) else {
            assertionFailure("Invalid amount input")
            return
        }
        
        do {
            let amount = try Amount(value: value)
            
            guard let cd = currentData as? CurrencyConverterViewModelDataImpl else {
                assertionFailure("Failed to cast currentData to CurrencyConverterViewModelDataImpl")
                return
            }
            
            currentData = CurrencyConverterViewModelDataImpl(source: cd.source,
                                                             inputAmount: amount,
                                                             target: cd.target,
                                                             outputAmount: cd.outputAmount)
            
            update()
            
        } catch {
            assertionFailure("Invalid amount input \(error)")
        }
    }
    
    func isValidAmount(_ amount: String) -> Bool {
        nil != Double(amount)
    }
    
    var currencyConverterPublisher: Published<CurrencyConverterViewModelData>.Publisher { $currentData }
    var loadingStatePublisher: Published<CurrencyConverterLoadingState>.Publisher { $state }
}

private extension CurrencyConverterViewModelImpl {
    func update() {
        
        bindings.removeAll()
        
        guard let cd = currentData as? CurrencyConverterViewModelDataImpl else {
            assertionFailure("Failed to cast currentData to CurrencyConverterViewModelDataImpl")
            return
        }
        
        state = .loading
        
        let request = CurrencyConversionRequest(sourceCurrency: cd.source,
                                                targetCurrency: cd.target,
                                                amount: cd.inputAmount)
        
        networkManager.getCurrencyConversion(from: request)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self else { return }
                
                switch completion {
                case .failure(let modelError):
                    self.state = .error(modelError)
                case .finished:
                    self.state = .finishedLoading
                }
                
            } receiveValue: { [weak self] response in
                guard let self,
                      let cd = self.currentData as? CurrencyConverterViewModelDataImpl
                else { return }
                
                self.currentData = CurrencyConverterViewModelDataImpl(source: cd.source,
                                                                      inputAmount: cd.inputAmount,
                                                                      target: response.currency,
                                                                      outputAmount: response.amount)
            }
            .store(in: &bindings)
    }
}

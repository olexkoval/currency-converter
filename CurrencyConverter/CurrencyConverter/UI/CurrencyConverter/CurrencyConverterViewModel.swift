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
    case failure(Error)
}

protocol CurrencyConverterViewModel: AnyObject {
    func sourceCurrencyChanged(_ sourceCurrencyISOCode: String)
    func targetCurrencyChanged(_ targetCurrencyISOCode: String)
    func amountChanged(_ amount: String)
    
    func onAppear()
    
    func shouldChangeCharactersFrom(currentText: String, in range: NSRange, replacementString string: String) -> Bool
    func validateAmountInput(amount: String) -> String
    
    var currencyConverterPublisher: Published<CurrencyConverterViewModelData>.Publisher { get }
    var loadingStatePublisher: Published<CurrencyConverterLoadingState>.Publisher { get }
}

final class CurrencyConverterViewModelImpl {
    private let recentCurrenciesManager: RecentCurrenciesManager
    private let networkManager: CurrencyConversionNetworkManager
    
    @Published private(set) var currentData: CurrencyConverterViewModelData
    @Published private(set) var state: CurrencyConverterLoadingState = .finishedLoading
    
    private var bindings = Set<AnyCancellable>()
    
    private var timer: Timer?
    private let amountInputDebouncer = Debouncer(delay: 0.3)
    
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
            let sourceCurrency = try Currency(currencyISOCode: sourceCurrencyISOCode)
            
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
            let targetCurrency = try Currency(currencyISOCode: targetCurrencyISOCode)
            
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
            
            amountInputDebouncer.debounce { [weak self] in
                self?.update()
            }
        } catch {
            assertionFailure("Invalid amount input \(error)")
        }
    }
    
    var currencyConverterPublisher: Published<CurrencyConverterViewModelData>.Publisher { $currentData }
    var loadingStatePublisher: Published<CurrencyConverterLoadingState>.Publisher { $state }
    
    private static let allowedAmountCharactersSet = CharacterSet(charactersIn: "0123456789.,").inverted
    
    func shouldChangeCharactersFrom(currentText: String, in range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: Self.allowedAmountCharactersSet) != nil {
            return false
        }

        var updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        updatedText = updatedText.replacingOccurrences(of: ",", with: ".")
        
        let components = updatedText.components(separatedBy: ".")
        if components.count > 2 {
            return false
        }
        
        if updatedText.isEmpty {
            return true
        }

        if let value = Double(updatedText),
        let _ = try? Amount(value: value) {
            return true
        }

        return false
    }
    
    func validateAmountInput(amount: String) -> String {
        if amount.isEmpty {
            return "0"
        }
        else {
            return amount.replacingOccurrences(of: ",", with: ".")
        }
    }
}

private extension CurrencyConverterViewModelImpl {
    
    func scheduleTimerUpdate() {
        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.update()
        }
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func update() {
        
        guard let cd = currentData as? CurrencyConverterViewModelDataImpl else {
            assertionFailure("Failed to cast currentData to CurrencyConverterViewModelDataImpl")
            return
        }
        
        let request = CurrencyConversionRequest(sourceCurrency: cd.source,
                                                targetCurrency: cd.target,
                                                amount: cd.inputAmount)
        
        if !request.isValid {
            currentData = CurrencyConverterViewModelDataImpl(source: cd.source,
                                                             inputAmount: .zero,
                                                             target: cd.target,
                                                             outputAmount: .zero)
            return
        }
        
        resetTimer()
        bindings.removeAll()
        
        state = .loading
 
        networkManager.getCurrencyConversion(from: request)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self else { return }
                
                switch completion {
                case .failure(let modelError):
                    self.state = .failure(modelError)
                    self.currentData = CurrencyConverterViewModelDataImpl(source: cd.source,
                                                                          inputAmount: .zero,
                                                                          target: cd.target,
                                                                          outputAmount: .zero)
                case .finished:
                    self.state = .finishedLoading
                    self.scheduleTimerUpdate()
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

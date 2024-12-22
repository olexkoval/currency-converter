//
//  DependencyRegistry.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import Foundation
import Swinject

protocol DependencyRegistry: AnyObject {
    func makeNavigationCoordinator() -> NavigationCoordinator
    func makeCurrencyPickerController() -> CurrencyPickerViewController
}

final class DependencyRegistryImpl {
    
    private var container: Container
    
    init(container: Container = Container()) {
        
        Container.loggingFunction = nil
        
        self.container = container
        
        registerDependencies()
        registerViewModels()
        registerViewControllers()
    }
}

extension DependencyRegistryImpl: DependencyRegistry {
    func makeCurrencyPickerController() -> CurrencyPickerViewController {
        container.resolve(CurrencyPickerViewController.self)!
    }
    
    func makeNavigationCoordinator() -> NavigationCoordinator {
        container.resolve(NavigationCoordinator.self)!
    }
}

private extension DependencyRegistryImpl {
    
    func registerDependencies() {
        container.register(NavigationCoordinator.self) { [weak self] r in
            NavigationCoordinatorImpl(rootViewController: r.resolve(CurrencyConverterViewController.self)!, registry: self!)
        }.inObjectScope(.container)
        
        container.register(CurrencyConversionNetworkManager.self) { _ in CurrencyConversionNetworkManagerImpl() }.inObjectScope(.container)
        container.register(RecentCurrenciesManager.self) { _ in RecentCurrenciesManagerImpl() }.inObjectScope(.container)
    }
    
    func registerViewModels() {
        container.register(CurrencyConverterViewModel.self) { r in CurrencyConverterViewModelImpl(recentCurrenciesManager: r.resolve(RecentCurrenciesManager.self)!, networkManager:r.resolve(CurrencyConversionNetworkManager.self)!) }
        
        container.register(CurrencyPickerViewModel.self) { r in CurrencyPickerViewModelImpl(recentCurrenciesManager: r.resolve(RecentCurrenciesManager.self)!) }
    }
    
    func registerViewControllers() {
        container.register(CurrencyConverterViewController.self) { r in
            CurrencyConverterViewController(viewModel: r.resolve(CurrencyConverterViewModel.self)!)
        }
        .initCompleted { r, vc in
            vc.navigationCoordinator = r.resolve(NavigationCoordinator.self)!
        }
        
        container.register(CurrencyPickerViewController.self) { r in
            CurrencyPickerViewController(viewModel: r.resolve(CurrencyPickerViewModel.self)!)
        }
    }
}

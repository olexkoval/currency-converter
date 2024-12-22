//
//  NavigationCoordinator.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import UIKit

protocol NavigationCoordinator: AnyObject {
    var rootViewController: UIViewController { get }
    func showError(_ error: Error)
    func presentCurrencyPicker(for selectedCurrency: String?, completion: @escaping (String?) -> Void)
}

final class NavigationCoordinatorImpl {
    private(set) weak var registry: DependencyRegistry?
    let rootViewController: UIViewController
    private var currencyPickerCompletion: ((String?) -> Void)?
    
    init(rootViewController: UIViewController, registry: DependencyRegistry) {
        self.rootViewController = rootViewController
        self.registry = registry
    }
}

extension NavigationCoordinatorImpl: NavigationCoordinator {
    func showError(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            navigationController?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    func presentCurrencyPicker(for selectedCurrency: String?, completion: @escaping (String?) -> Void) {
        guard nil == currencyPickerCompletion else {
            assertionFailure("Currency picker already shown")
            return
        }
                
        guard let currencyPicker = registry?.makeCurrencyPickerController()
        else {
            assertionFailure("failed to obtain currency picker")
            return
        }
        
        currencyPickerCompletion = completion

        currencyPicker.delegate = self
        currencyPicker.selectedCurrencyISOCode = selectedCurrency
        
        self.navigationController?.present(currencyPicker, animated: true)
    }
}

extension NavigationCoordinatorImpl: CurrencyPickerViewControllerDelegate {
    func currencyPickerViewController(_ picker: CurrencyPickerViewController, didSelect currencyISOCode: String) {
        guard let currencyPickerCompletion else {
            assertionFailure("missed currencyPickerCompletion while picker appeared")
            return
        }
        
        self.currencyPickerCompletion = nil
        
        self.navigationController?.dismiss(animated: true, completion: {
            currencyPickerCompletion(currencyISOCode)
        })
    }
    
    func currencyPickerViewControllerDidCancel(_ picker: CurrencyPickerViewController) {
        guard let currencyPickerCompletion else {
            assertionFailure("missed currencyPickerCompletion while picker appeared")
            return
        }
        
        self.currencyPickerCompletion = nil
        
        self.navigationController?.dismiss(animated: true, completion: {
            currencyPickerCompletion(nil)
        })
    }
}

private extension NavigationCoordinatorImpl {
    var navigationController: UINavigationController? {
        guard let navigationController = rootViewController.navigationController 
        else {
            assertionFailure("Navigation Controller wasn't found")
            return nil
        }
        
        return navigationController
    }
}

//
//  SceneDelegate.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var dependencyRegistry: DependencyRegistry = DependencyRegistryImpl()
    private lazy var coordinator: NavigationCoordinator = dependencyRegistry.makeNavigationCoordinator()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: coordinator.rootViewController)
        window?.makeKeyAndVisible()
    }
}


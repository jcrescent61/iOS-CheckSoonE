//
//  SceneDelegate.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/03/30.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TabBarViewController()
        window?.backgroundColor = .white
        window?.overrideUserInterfaceStyle = .light
        window?.makeKeyAndVisible()
    }
}

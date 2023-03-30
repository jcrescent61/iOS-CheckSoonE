//
//  TabBarViewController.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/03/30.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarViewController()
        view.backgroundColor = .white
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .systemGray2
        tabBar.backgroundColor = .systemGray6
    }
    
    private func setTabBarViewController() {
        let homeViewController = UIViewController()
        homeViewController.tabBarItem.image = UIImage(systemName: "house")
        homeViewController.tabBarItem.title = "HOME"
        
        let scanViewController = UIViewController()
        scanViewController.tabBarItem.image = UIImage(systemName: "barcode.viewfinder")
        scanViewController.tabBarItem.title = "SCAN"
        
        let settingViewController = UIViewController()
        settingViewController.tabBarItem.image = UIImage(systemName: "line.3.horizontal")
        settingViewController.tabBarItem.title = "SETTING"
        
        viewControllers = [
            homeViewController,
            scanViewController,
            settingViewController
        ]
    }
}

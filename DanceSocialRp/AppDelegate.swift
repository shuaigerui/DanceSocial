//
//  AppDelegate.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit
import IQKeyboardManager
import Toast_Swift
@_exported import SnapKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        ToastManager.shared.position = .center
        
        initializeWindow()
        Task { await DS_IAPManager.shared.loadProducts() }

        return true
    }

    private func initializeWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let launchVC = DS_LaunchVC()
        launchVC.completion = {
            if DS_CurrentUser.shared.isLoggedIn {
                self.window?.rootViewController = DS_TabbarVC()
            } else {
                self.window?.rootViewController = UINavigationController(rootViewController: DS_WelcomeVC())
            }
        }
        window?.rootViewController = launchVC
        window?.makeKeyAndVisible()
    }

}


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
        
        return true
    }

    private func initializeWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)

        if DS_CurrentUser.shared.isLoggedIn {
            window?.rootViewController = DS_TabbarVC()
        } else {
            window?.rootViewController = UINavigationController(rootViewController: DS_WelcomeVC())
        }

        window?.makeKeyAndVisible()
    }

}


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

    private func initializeWindow(){
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window?.rootViewController = DS_TabbarVC()//UINavigationController(rootViewController: DS_WelcomeVC())
        self.window?.makeKeyAndVisible()
    }

}


//
//  DS_TabbarVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

enum DS_TabbarType: CaseIterable {
    case home
    case post
    case live
    case chat
    case profile

    var imageName: String {
        switch self {
        case .home:
            return "tab_home"
        case .post:
            return "tab_post"
        case .live:
            return "tab_live"
        case .chat:
            return "tab_chat"
        case .profile:
            return "tab_profile"
        }
    }

    var selImageName: String {
        "\(imageName)_sel"
    }

    var controller: UIViewController {
        switch self {
        case .home:
            return UINavigationController(rootViewController: DS_HomeVC())
        case .post:
            return UINavigationController(rootViewController: DS_PostVC())
        case .live:
            return UINavigationController(rootViewController: DS_LiveVC())
        case .chat:
            return UINavigationController(rootViewController: DS_ChatVC())
        case .profile:
            return UINavigationController(rootViewController: DS_ProfileVC())
        }
    }
}

class DS_TabbarVC: UITabBarController {

    init() {
        super.init(nibName: nil, bundle: nil)
        setValue(DS_TabBar(), forKey: "tabBar")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViewControllers()
        setupTabBarAppearance()
    }

    private func setupViewControllers() {
        viewControllers = DS_TabbarType.allCases.map { type in
            let controller = type.controller
            controller.tabBarItem = makeTabBarItem(for: type)
            return controller
        }
        selectedIndex = 0
    }

    private func makeTabBarItem(for type: DS_TabbarType) -> UITabBarItem {
        let item = UITabBarItem(
            title: nil,
            image: UIImage(named: type.imageName)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: type.selImageName)?.withRenderingMode(.alwaysOriginal)
        )
        item.accessibilityLabel = String(describing: type)
        item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        return item
    }

    private func setupTabBarAppearance() {
        tabBar.isTranslucent = false
        tabBar.tintColor = .clear
        tabBar.unselectedItemTintColor = .clear
        tabBar.backgroundColor = .clear
        tabBar.barTintColor = .black
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.selectionIndicatorImage = UIImage()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        [appearance.stackedLayoutAppearance,
         appearance.inlineLayoutAppearance,
         appearance.compactInlineLayoutAppearance].forEach {
            $0.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            $0.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
        }

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    static func switchToMainInterface(animated: Bool = true) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow }) else {
            return
        }

        let tabBarController = DS_TabbarVC()
        guard animated else {
            window.rootViewController = tabBarController
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = tabBarController
        }
    }
}

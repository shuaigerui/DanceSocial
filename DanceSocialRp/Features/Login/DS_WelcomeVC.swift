//
//  DS_WelcomeVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_WelcomeVC: DS_BaseVC {

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "login_welcomeBg"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var appleSignInButton = makeActionButton(
        title: "Sign in with Apple",
        systemImageName: "apple.logo"
    )

    private lazy var createAccountButton = makeActionButton(title: "Create Account")

    private lazy var signInButton = makeActionButton(title: "Sign in")

    private lazy var actionStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            appleSignInButton,
            createAccountButton,
            signInButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.35, green: 0.22, blue: 0.75, alpha: 1)

        view.addSubview(backgroundImageView)
        view.addSubview(actionStackView)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        actionStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(48)
        }

        [appleSignInButton, createAccountButton, signInButton].forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(52)
            }
        }
    }

    private func setupActions() {
        appleSignInButton.addTarget(self, action: #selector(didTapAppleSignIn), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }

    private func makeActionButton(title: String, systemImageName: String? = nil) -> UIButton {
        let button = UIButton(type: .custom)

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.cornerStyle = .capsule
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var attributes = incoming
            attributes.font = .systemFont(ofSize: 17, weight: .semibold)
            return attributes
        }

        if let systemImageName {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            config.image = UIImage(systemName: systemImageName, withConfiguration: symbolConfig)
            config.imagePadding = 8
            config.imagePlacement = .leading
        }

        button.configuration = config
        return button
    }

    @objc private func didTapAppleSignIn() {
        navigationController?.pushViewController(DS_SetupInfoVC(source: .apple), animated: true)
    }

    @objc private func didTapCreateAccount() {
        navigationController?.pushViewController(DS_LoginVC(mode: .register), animated: true)
    }

    @objc private func didTapSignIn() {
        navigationController?.pushViewController(DS_LoginVC(mode: .login), animated: true)
    }
}

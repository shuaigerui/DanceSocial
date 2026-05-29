//
//  DS_LoginVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit
import Toast_Swift

enum DS_LoginMode {
    case login
    case register
}

class DS_LoginVC: DS_BaseVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 24
        static let fieldHeight: CGFloat = 50
        static let fieldRightIconInset: CGFloat = 15
        static let fieldRightIconSize: CGFloat = 44
        static let linkColor = UIColor(red: 232 / 255, green: 148 / 255, blue: 77 / 255, alpha: 1)
    }

    private var mode: DS_LoginMode

    init(mode: DS_LoginMode = .login) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let topImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "login_topView"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let formContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
//        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
//        button.tintColor = .white
        button.setImage(UIImage(named: "common_back"), for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to join us"
        label.textColor = .white
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let mailTitleLabel = DS_LoginVC.makeFieldTitleLabel(text: "Mail")
    private let passwordTitleLabel = DS_LoginVC.makeFieldTitleLabel(text: "Password")

    private lazy var mailTextField = makeTextField(
        placeholder: "",
        keyboardType: .emailAddress,
        rightView: mailClearButton
    )

    private lazy var passwordTextField = makeTextField(
        placeholder: "",
        keyboardType: .default,
        rightView: passwordVisibilityButton
    )

    private lazy var mailClearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "login_clear"), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapClearMail), for: .touchUpInside)
        return button
    }()

    private lazy var passwordVisibilityButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "login_hidden"), for: .normal)
        button.setImage(UIImage(named: "login_show"), for: .selected)
        button.addTarget(self, action: #selector(didTapTogglePassword), for: .touchUpInside)
        return button
    }()

    private lazy var switchModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(didTapSwitchMode), for: .touchUpInside)
        return button
    }()

    private lazy var primaryActionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTapPrimaryAction), for: .touchUpInside)
        return button
    }()

    private var isPasswordVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyMode(animated: false)
        setupTextFieldObservers()
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(topImageView)
        view.addSubview(formContainerView)
        view.addSubview(backButton)

        [
            titleLabel,
            subtitleLabel,
            mailTitleLabel,
            mailTextField,
            passwordTitleLabel,
            passwordTextField,
            switchModeButton,
            primaryActionButton
        ].forEach { formContainerView.addSubview($0) }

        topImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(230)
        }

        formContainerView.snp.makeConstraints { make in
            make.top.equalTo(topImageView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(4)
            make.width.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
        }

        mailTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(28)
            make.leading.trailing.equalTo(titleLabel)
        }

        mailTextField.snp.makeConstraints { make in
            make.top.equalTo(mailTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(Layout.fieldHeight)
        }

        passwordTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(mailTextField.snp.bottom).offset(20)
            make.leading.trailing.equalTo(titleLabel)
        }

        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(Layout.fieldHeight)
        }

        switchModeButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.leading.trailing.equalTo(titleLabel)
        }

        primaryActionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(64)
            make.width.equalTo(267)
        }
    }

    private func setupTextFieldObservers() {
        mailTextField.addTarget(self, action: #selector(mailTextDidChange), for: .editingChanged)
        mailTextField.delegate = self
        passwordTextField.delegate = self
    }

    private func applyMode(animated: Bool) {
        let updates = {
            switch self.mode {
            case .login:
                self.subtitleLabel.text = "Log in to share and discuss topics"
                self.primaryActionButton.setBackgroundImage(UIImage(named: "login_next"), for: .normal)
                self.primaryActionButton.accessibilityLabel = "Next"
                self.switchModeButton.setAttributedTitle(
                    self.makeSwitchModeTitle(
                        prefix: "Don't have an account yet? ",
                        action: "Create Account"
                    ),
                    for: .normal
                )
            case .register:
                self.subtitleLabel.text = "Register to share and discuss topics."
                self.primaryActionButton.setBackgroundImage(UIImage(named: "login_createAcc"), for: .normal)
                self.primaryActionButton.accessibilityLabel = "Create Account"
                self.switchModeButton.setAttributedTitle(
                    self.makeSwitchModeTitle(
                        prefix: "Already have an account? ",
                        action: "Sign in"
                    ),
                    for: .normal
                )
            }
        }

        guard animated else {
            updates()
            return
        }

        UIView.transition(with: formContainerView, duration: 0.25, options: .transitionCrossDissolve) {
            updates()
        }
    }

    private func makeSwitchModeTitle(prefix: String, action: String) -> NSAttributedString {
        let full = prefix + action
        let attributed = NSMutableAttributedString(
            string: full,
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.8),
                .font: UIFont.systemFont(ofSize: 15, weight: .regular)
            ]
        )
        attributed.addAttributes(
            [
                .foregroundColor: Layout.linkColor,
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
            ],
            range: NSRange(location: prefix.count, length: action.count)
        )
        return attributed
    }

    private static func makeFieldTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }

    private func makeTextFieldRightView(with button: UIButton) -> UIView {
        let inset = Layout.fieldRightIconInset
        let buttonSize = Layout.fieldRightIconSize
        let containerWidth = inset + buttonSize
        let container = UIView(
            frame: CGRect(x: 0, y: 0, width: containerWidth, height: Layout.fieldHeight)
        )
        button.frame = CGRect(
            x: 0,
            y: (Layout.fieldHeight - buttonSize) / 2,
            width: buttonSize,
            height: buttonSize
        )
        container.addSubview(button)
        return container
    }

    private func makeTextField(
        placeholder: String,
        keyboardType: UIKeyboardType,
        rightView: UIButton
    ) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = Layout.fieldHeight / 2
        textField.clipsToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: Layout.fieldHeight))
        textField.leftViewMode = .always
        textField.rightView = makeTextFieldRightView(with: rightView)
        textField.rightViewMode = .always
        textField.returnKeyType = .next
        textField.clearButtonMode = .never
        if keyboardType == .emailAddress {
            textField.textContentType = .username
        } else {
            textField.textContentType = .password
            textField.isSecureTextEntry = true
        }
        return textField
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapSwitchMode() {
        mode = mode == .login ? .register : .login
        applyMode(animated: true)
    }

    @objc private func didTapPrimaryAction() {
        view.endEditing(true)

        let account = mailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""

        switch mode {
        case .login:
            guard !account.isEmpty, !password.isEmpty else {
                view.makeToast("Please enter account and password")
                return
            }
            if DS_CurrentUser.shared.signIn(account: account, password: password) {
                return
            }
            view.makeToast("Invalid account or password")
        case .register:
            guard !account.isEmpty, !password.isEmpty else {
                view.makeToast("Please enter account and password")
                return
            }
            navigationController?.pushViewController(
                DS_SetupInfoVC(source: .register(account: account, password: password)),
                animated: true
            )
        }
    }

    @objc private func didTapClearMail() {
        mailTextField.text = nil
        mailClearButton.isHidden = true
    }

    @objc private func didTapTogglePassword() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        passwordVisibilityButton.isSelected = isPasswordVisible
    }

    @objc private func mailTextDidChange() {
        mailClearButton.isHidden = mailTextField.text?.isEmpty != false
    }
}

extension DS_LoginVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === mailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapPrimaryAction()
        }
        return true
    }
}

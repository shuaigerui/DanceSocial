//
//  DS_SetupInfoVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit
import PhotosUI
import Toast_Swift

enum DS_SetupInfoSource {
    case register(account: String, password: String)
    case apple
}

class DS_SetupInfoVC: DS_BaseVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 24
        static let fieldHeight: CGFloat = 50
        static let avatarSize: CGFloat = 120
        static let editButtonSize: CGFloat = 36
        static let linkColor = UIColor(red: 232 / 255, green: 148 / 255, blue: 77 / 255, alpha: 1)
    }

    private let source: DS_SetupInfoSource
    private var selectedAvatarImage: UIImage?

    init(source: DS_SetupInfoSource) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(source: .register(account: "", password: ""))
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
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
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
        label.text = "Register to share and discuss topics."
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let avatarContainerView = UIView()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(white: 0.55, alpha: 1)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var avatarEditButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "login_pic"), for: .normal)
        button.addTarget(self, action: #selector(didTapAvatar), for: .touchUpInside)
        return button
    }()

    private let nameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = Layout.fieldHeight / 2
        textField.clipsToBounds = true
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.textContentType = .name
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: Layout.fieldHeight))
        textField.leftViewMode = .always
        textField.delegate = self
        return textField
    }()

    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0
        button.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        return button
    }()

    private lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "login_createAcc"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.accessibilityLabel = "Create Account"
        button.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSignInTitle()
        setupAvatarTap()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = Layout.avatarSize / 2
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(topImageView)
        view.addSubview(formContainerView)
        view.addSubview(backButton)

        [
            titleLabel,
            subtitleLabel,
            avatarContainerView,
            nameTitleLabel,
            nameTextField,
            signInButton,
            createAccountButton
        ].forEach { formContainerView.addSubview($0) }

        avatarContainerView.addSubview(avatarImageView)
        avatarContainerView.addSubview(avatarEditButton)

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

        avatarContainerView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(Layout.avatarSize + 8)
            make.height.equalTo(Layout.avatarSize + 8)
        }

        avatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(Layout.avatarSize)
        }

        avatarEditButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(avatarImageView)
            make.width.height.equalTo(Layout.editButtonSize)
        }

        nameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView.snp.bottom).offset(28)
            make.leading.trailing.equalTo(titleLabel)
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(Layout.fieldHeight)
        }

        signInButton.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        createAccountButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(64)
            make.width.equalTo(267)
        }
    }

    private func setupSignInTitle() {
        let prefix = "Already have an account? "
        let action = "Sign in"
        let attributed = NSMutableAttributedString(
            string: prefix + action,
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
        signInButton.setAttributedTitle(attributed, for: .normal)
    }

    private func setupAvatarTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar))
        avatarImageView.addGestureRecognizer(tap)
    }

    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func updateAvatar(with image: UIImage) {
        selectedAvatarImage = image
        avatarImageView.image = image
        avatarImageView.backgroundColor = .clear
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapAvatar() {
        presentPhotoPicker()
    }

    @objc private func didTapSignIn() {
        guard let navigationController else { return }

        let loginVC = DS_LoginVC(mode: .login)
        if let loginIndex = navigationController.viewControllers.firstIndex(where: { $0 is DS_LoginVC }) {
            var viewControllers = Array(navigationController.viewControllers.prefix(loginIndex))
            viewControllers.append(loginVC)
            navigationController.setViewControllers(viewControllers, animated: true)
        } else {
            navigationController.pushViewController(loginVC, animated: true)
        }
    }

    @objc private func didTapCreateAccount() {
        view.endEditing(true)

        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty else {
            view.makeToast("Please enter your name")
            return
        }

        switch source {
        case .register(let account, let password):
            guard !account.isEmpty else {
                view.makeToast("Invalid account")
                return
            }
            DS_CurrentUser.shared.registerUser(
                account: account,
                password: password,
                userName: name,
                avatarImage: selectedAvatarImage
            )
        case .apple:
            DS_CurrentUser.shared.registerAppleUser(
                userName: name,
                avatarImage: selectedAvatarImage
            )
        }

        DS_CurrentUser.shared.enterMainInterface()
    }
}

extension DS_SetupInfoVC: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.updateAvatar(with: image)
            }
        }
    }
}

extension DS_SetupInfoVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//
//  DS_ReviseVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit
import PhotosUI

class DS_ReviseVC: DS_SecondaryVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 24
        static let navBarHeight: CGFloat = 44
        static let avatarSize: CGFloat = 200
        static let avatarCornerRadius: CGFloat = 40
        static let avatarBorderWidth: CGFloat = 2
        static let editButtonSize: CGFloat = 40
        static let fieldHeight: CGFloat = 50
        static let buttonAspect: CGFloat = 192.0 / 801.0
    }

    private var selectedAvatarImage: UIImage?

    private let navBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_back"), for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Revise"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "login_pic"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#555555")
        imageView.layer.cornerRadius = 88
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var avatarEditButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "revise_pic"), for: .normal)
        button.addTarget(self, action: #selector(didTapAvatar), for: .touchUpInside)
        return button
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter a new name",
            attributes: [
                .foregroundColor: UIColor.hex("#999999"),
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textAlignment = .center
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 24
        textField.clipsToBounds = true
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.textContentType = .name
        textField.delegate = self
        return textField
    }()

    private lazy var reviseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "revise_button"), for: .normal)
        button.addTarget(self, action: #selector(didTapRevise), for: .touchUpInside)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAvatarTap()
    }
    
    
    private func loadData() {
        guard let user = DS_CurrentUser.shared.user else { return }

        nameTextField.text = user.userName
        selectedAvatarImage = nil

        if let image = DS_CurrentUser.shared.avatarImage(for: user) {
            avatarImageView.image = image
            avatarImageView.backgroundColor = .clear
        } else {
            avatarImageView.image = UIImage(named: "login_pic")
            avatarImageView.backgroundColor = UIColor.hex("#555555")
        }
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(navBarView)
        view.addSubview(avatarImageView)
        view.addSubview(avatarEditButton)
        view.addSubview(nameTextField)
        view.addSubview(reviseButton)

        navBarView.addSubview(backButton)
        navBarView.addSubview(titleLabel)

        navBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.navBarHeight)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(navBarView.snp.bottom).offset(15)
            make.width.height.equalTo(265)
        }

        avatarEditButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(avatarImageView).offset(4)
            make.width.height.equalTo(Layout.editButtonSize)
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(66)
            make.centerX.equalToSuperview()
            make.height.equalTo(58)
            make.width.equalTo(240)
        }

        reviseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameTextField.snp.bottom).offset(40)
            make.height.equalTo(64)
            make.width.equalTo(267)
        }
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

    @objc private func didTapRevise() {
        view.endEditing(true)
        guard DS_CurrentUser.shared.updateProfile(
            userName: nameTextField.text,
            avatarImage: selectedAvatarImage
        ) else {
            return
        }
        navigationController?.popViewController(animated: true)
    }
}

extension DS_ReviseVC: PHPickerViewControllerDelegate {

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

extension DS_ReviseVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

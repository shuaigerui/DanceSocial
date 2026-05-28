//
//  DS_CreateLiveVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit
import PhotosUI

class DS_CreateLiveVC: DS_SecondaryVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let fieldHeight: CGFloat = 50
        static let fieldCornerRadius: CGFloat = 25
        static let coverHeight: CGFloat = 220
        static let coverCornerRadius: CGFloat = 20
        static let confirmAspect: CGFloat = 192.0 / 801.0
    }

    private var selectedCoverImage: UIImage?

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_back"), for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private let titleSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        return label
    }()

    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Chat room title",
            attributes: [
                .foregroundColor: UIColor.hex("#999999"),
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.backgroundColor = UIColor.hex("#F1F1F1")
        textField.layer.cornerRadius = Layout.fieldCornerRadius
        textField.clipsToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: Layout.fieldHeight))
        textField.leftViewMode = .always
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()

    private let coverSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Cover"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        return label
    }()

    private lazy var coverUploadButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = Layout.coverCornerRadius
        button.clipsToBounds = true
        button.setImage(UIImage(named: "push_add"), for: .normal)
        button.addTarget(self, action: #selector(didTapCover), for: .touchUpInside)
        return button
    }()

    private let coverPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Layout.coverCornerRadius
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "shop_confirm"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCoverTap()
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(backButton)
        view.addSubview(titleSectionLabel)
        view.addSubview(titleTextField)
        view.addSubview(coverSectionLabel)
        view.addSubview(coverUploadButton)
        view.addSubview(coverPreviewImageView)
        view.addSubview(confirmButton)

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(4)
            make.width.height.equalTo(44)
        }

        titleSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
        }

        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(titleSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.fieldHeight)
        }

        coverSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(28)
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
        }

        coverUploadButton.snp.makeConstraints { make in
            make.top.equalTo(coverSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.coverHeight)
        }

        coverPreviewImageView.snp.makeConstraints { make in
            make.edges.equalTo(coverUploadButton)
        }

        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.height.equalTo(64)
            make.width.equalTo(267)
        }
    }

    private func setupCoverTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCover))
        coverPreviewImageView.addGestureRecognizer(tap)
    }

    private func presentCoverPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func applyCoverPreview(_ image: UIImage) {
        selectedCoverImage = image
        coverPreviewImageView.image = image
        coverPreviewImageView.isHidden = false
        coverUploadButton.setImage(nil, for: .normal)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapCover() {
        presentCoverPicker()
    }

    @objc private func didTapConfirm() {
        view.endEditing(true)
        // TODO: submit titleTextField.text and selectedCoverImage
        navigationController?.popViewController(animated: true)
    }
}

extension DS_CreateLiveVC: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.applyCoverPreview(image)
            }
        }
    }
}

extension DS_CreateLiveVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

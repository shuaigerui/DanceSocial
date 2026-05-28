//
//  DS_PushPostVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import PhotosUI
import Toast_Swift
import UIKit
import UniformTypeIdentifiers

enum DS_PushReleaseType: Int {
    case instant = 0
    case video = 1

    var normalImageName: String {
        switch self {
        case .instant: return "push_instant"
        case .video: return "push_video"
        }
    }

    var selectedImageName: String {
        switch self {
        case .instant: return "push_instant_sel"
        case .video: return "push_video_sel"
        }
    }
}

class DS_PushPostVC: DS_SecondaryVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let navBarHeight: CGFloat = 44
        static let segmentHeight: CGFloat = 40
        static let textViewMinHeight: CGFloat = 180
        static let textCornerRadius: CGFloat = 20
        static let addButtonSize: CGFloat = 96
        static let confirmAspect: CGFloat = 192.0 / 801.0
    }

    private var selectedType: DS_PushReleaseType = .instant
    private var selectedMediaImage: UIImage?
    private var selectedVideoFileURL: URL?

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_back"), for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private lazy var instantButton = makeSegmentButton(for: .instant)
    private lazy var videoButton = makeSegmentButton(for: .video)

    private lazy var segmentButtons: [UIButton] = [instantButton, videoButton]

    private lazy var segmentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [instantButton, videoButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()

    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.hex("#F1F1F1")
        textView.textColor = .black
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.layer.cornerRadius = Layout.textCornerRadius
        textView.clipsToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 14, bottom: 16, right: 14)
        textView.autocorrectionType = .default
        return textView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Tell me about your troubles."
        label.textColor = UIColor.hex("#999999")
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private lazy var addMediaButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "push_add"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didTapAddMedia), for: .touchUpInside)
        return button
    }()

    private let mediaPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let costLabel: UILabel = {
        let label = UILabel()
        label.text = "Unlocking dynamic posting costs 10 gold coins."
        label.textColor = UIColor(hex: "#999999")
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "shop_confirm"), for: .normal)
        button.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateTabSelection(.instant)
        contentTextView.delegate = self
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(backButton)
        view.addSubview(segmentStackView)
        view.addSubview(contentTextView)
        view.addSubview(placeholderLabel)
        view.addSubview(addMediaButton)
        view.addSubview(mediaPreviewImageView)
        view.addSubview(costLabel)
        view.addSubview(confirmButton)

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(6)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.height.equalTo(44)
        }

        segmentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(backButton.snp.bottom).offset(15)
            make.height.equalTo(Layout.segmentHeight)
        }

        segmentButtons.forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(Layout.segmentHeight)
            }
        }

        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(segmentStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(Layout.textViewMinHeight)
        }

        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTextView).offset(16)
            make.leading.equalTo(contentTextView).offset(18)
            make.trailing.equalTo(contentTextView).offset(-18)
        }

        addMediaButton.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.width.height.equalTo(132)
        }

        mediaPreviewImageView.snp.makeConstraints { make in
            make.edges.equalTo(addMediaButton)
        }

        costLabel.snp.makeConstraints { make in
            make.bottom.equalTo(confirmButton.snp.top).offset(-20)
            make.leading.trailing.equalToSuperview().inset(25)
        }

        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.height.equalTo(64)
            make.width.equalTo(267)
        }
    }

    private func makeSegmentButton(for type: DS_PushReleaseType) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: type.normalImageName), for: .normal)
        button.setImage(UIImage(named: type.selectedImageName), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        button.tag = type.rawValue
        button.addTarget(self, action: #selector(didTapSegment(_:)), for: .touchUpInside)
        return button
    }

    private func updateTabSelection(_ type: DS_PushReleaseType) {
        selectedType = type
        segmentButtons.enumerated().forEach { index, button in
            button.isSelected = index == type.rawValue
        }
        clearSelectedMedia()
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !contentTextView.text.isEmpty
    }

    private func clearSelectedMedia() {
        selectedMediaImage = nil
        selectedVideoFileURL = nil
        mediaPreviewImageView.image = nil
        mediaPreviewImageView.isHidden = true
        addMediaButton.setImage(UIImage(named: "push_add"), for: .normal)
        addMediaButton.backgroundColor = .white
    }

    private func presentMediaPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = selectedType == .video ? .videos : .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func applyMediaPreview(_ image: UIImage) {
        selectedMediaImage = image
        mediaPreviewImageView.image = image
        mediaPreviewImageView.isHidden = false
        addMediaButton.setImage(nil, for: .normal)
        addMediaButton.backgroundColor = .clear
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapSegment(_ sender: UIButton) {
        guard let type = DS_PushReleaseType(rawValue: sender.tag) else { return }
        updateTabSelection(type)
    }

    @objc private func didTapAddMedia() {
        presentMediaPicker()
    }

    @objc private func didTapConfirm() {
        view.endEditing(true)

        let content = contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.isEmpty {
            view.makeToast("Please enter a description")
            return
        }

        let didPublish: Bool
        switch selectedType {
        case .instant:
            guard let image = selectedMediaImage else {
                view.makeToast("Please select an image or video")
                return
            }
            didPublish = DS_CurrentUser.shared.addPost(
                content: content,
                mediaType: .image,
                image: image,
                videoSourceURL: nil
            )
        case .video:
            guard let videoURL = selectedVideoFileURL else {
                view.makeToast("Please select an image or video")
                return
            }
            didPublish = DS_CurrentUser.shared.addPost(
                content: content,
                mediaType: .video,
                image: nil,
                videoSourceURL: videoURL
            )
        }

        guard didPublish else {
            view.makeToast("Failed to publish post")
            return
        }

        view.makeToast("Post created successfully")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    private func importPickedVideo(from tempURL: URL) {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Posts", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let destinationURL = directory.appendingPathComponent("pick_\(UUID().uuidString).mp4")
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: tempURL, to: destinationURL)
        } catch {
            return
        }

        selectedVideoFileURL = destinationURL
        DS_VideoThumbnailLoader.thumbnail(for: destinationURL.path) { [weak self] image in
            guard let image else { return }
            DispatchQueue.main.async {
                self?.applyMediaPreview(image)
            }
        }
    }
}

extension DS_PushPostVC: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
}

extension DS_PushPostVC: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider else { return }

        if selectedType == .instant, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                guard let image = object as? UIImage else { return }
                DispatchQueue.main.async {
                    self?.selectedVideoFileURL = nil
                    self?.applyMediaPreview(image)
                }
            }
            return
        }

        if selectedType == .video,
           itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, _ in
                guard let url else { return }
                self?.importPickedVideo(from: url)
            }
        }
    }
}

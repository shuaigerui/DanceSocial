//
//  DS_VideoRoomVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import AVFoundation
import UIKit

class DS_VideoRoomVC: DS_SecondaryVC {

    private enum Layout {
        static let backButtonSize: CGFloat = 44
        static let remoteSize = CGSize(width: 112, height: 150)
        static let remoteCornerRadius: CGFloat = 14
        static let remoteTopInset: CGFloat = 56
        static let remoteTrailingInset: CGFloat = 16
        static let controlBarHeight: CGFloat = 72
        static let controlBarHorizontalInset: CGFloat = 24
        static let controlBarBottomInset: CGFloat = 28
        static let controlBarCornerRadius: CGFloat = 36
        static let controlButtonSize: CGFloat = 52
        static let controlButtonSpacing: CGFloat = 28
    }

    private let peerName: String
    private let peerAvatarPath: String?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var audioDeviceInput: AVCaptureDeviceInput?
    private var currentCameraPosition: AVCaptureDevice.Position = .front

    private var isVideoEnabled = true
    private var isMicEnabled = true
    private var didCheckPermissions = false
    private var isCaptureConfigured = false

    private let cameraPreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_back"), for: .normal)
        button.addTarget(self, action: #selector(didTapEndCall), for: .touchUpInside)
        return button
    }()

    private let remoteContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#2C2C2E")
        view.layer.cornerRadius = Layout.remoteCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let remoteAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.hex("#444444")
        return imageView
    }()

    private let remoteLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let controlBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Layout.controlBarCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private lazy var switchCameraButton = makeControlButton(
        imageName: "video_reverse",
        action: #selector(didTapSwitchCamera)
    )

    private lazy var videoToggleButton = makeControlButton(
        imageName: "video_video",
        action: #selector(didTapToggleVideo)
    )

    private lazy var micToggleButton = makeControlButton(
        imageName: "video_mic",
        action: #selector(didTapToggleMic)
    )

    private lazy var hangUpButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "video_off"), for: .normal)
        button.addTarget(self, action: #selector(didTapEndCall), for: .touchUpInside)
        return button
    }()

    private lazy var controlStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            switchCameraButton,
            videoToggleButton,
            micToggleButton,
            hangUpButton
        ])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()

    init(peerName: String, peerAvatarPath: String? = nil) {
        self.peerName = peerName
        self.peerAvatarPath = peerAvatarPath
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyPeerInfo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didCheckPermissions else { return }
        didCheckPermissions = true
        checkMediaPermissions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraPreviewView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCaptureSession()
    }

    private func setupUI() {
        view.addSubview(cameraPreviewView)
        view.addSubview(backButton)
        view.addSubview(remoteContainerView)
        remoteContainerView.addSubview(remoteAvatarImageView)
        remoteContainerView.addSubview(remoteLoadingIndicator)
        view.addSubview(controlBarView)
        controlBarView.addSubview(controlStackView)

        cameraPreviewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(4)
            make.width.height.equalTo(Layout.backButtonSize)
        }

        remoteContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Layout.remoteTopInset)
            make.trailing.equalToSuperview().inset(Layout.remoteTrailingInset)
            make.size.equalTo(Layout.remoteSize)
        }

        remoteAvatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        remoteLoadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        controlBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.controlBarHorizontalInset)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Layout.controlBarBottomInset)
            make.height.equalTo(Layout.controlBarHeight)
        }

        controlStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        [switchCameraButton, videoToggleButton, micToggleButton, hangUpButton].forEach { button in
            button.snp.makeConstraints { make in
                make.width.height.equalTo(Layout.controlButtonSize)
            }
        }

        remoteLoadingIndicator.startAnimating()
    }

    private func makeControlButton(imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func applyPeerInfo() {
        remoteAvatarImageView.image = UserData.image(for: peerAvatarPath)
            ?? UIImage(named: peerAvatarPath ?? "")
    }

    // MARK: - Permissions

    private func checkMediaPermissions() {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)

        if cameraStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.checkMediaPermissions()
                }
            }
            return
        }

        if micStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.checkMediaPermissions()
                }
            }
            return
        }

        guard cameraStatus == .authorized, micStatus == .authorized else {
            presentPermissionAlert()
            return
        }

        configureCaptureSessionIfNeeded()
    }

    private func presentPermissionAlert() {
        let alert = UIAlertController(
            title: "Permissions Required",
            message: "Camera and microphone access are required for video chat. Please enable them in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        present(alert, animated: true)
    }

    // MARK: - Camera

    private func configureCaptureSessionIfNeeded() {
        guard !isCaptureConfigured else {
            startCaptureSession()
            return
        }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high

        defer {
            captureSession.commitConfiguration()
            isCaptureConfigured = true
            startCaptureSession()
        }

        if let videoInput = makeVideoInput(position: currentCameraPosition) {
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                videoDeviceInput = videoInput
            }
        }

        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
            audioDeviceInput = audioInput
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = cameraPreviewView.bounds
        cameraPreviewView.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }

    private func makeVideoInput(position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return nil
        }
        return input
    }

    private func startCaptureSession() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    private func stopCaptureSession() {
        guard captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    private func switchCamera() {
        let nextPosition: AVCaptureDevice.Position = currentCameraPosition == .front ? .back : .front
        guard let newInput = makeVideoInput(position: nextPosition) else { return }

        captureSession.beginConfiguration()
        if let videoDeviceInput {
            captureSession.removeInput(videoDeviceInput)
        }
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            videoDeviceInput = newInput
            currentCameraPosition = nextPosition
        }
        captureSession.commitConfiguration()
    }

    private func updateVideoEnabled(_ enabled: Bool) {
        isVideoEnabled = enabled
        videoToggleButton.setImage(
            UIImage(named: enabled ? "video_video" : "video_video_off"),
            for: .normal
        )
        cameraPreviewView.isHidden = !enabled
        captureSession.connections.forEach { connection in
            guard connection.inputPorts.contains(where: { $0.mediaType == .video }) else { return }
            connection.isEnabled = enabled
        }
    }

    private func updateMicEnabled(_ enabled: Bool) {
        isMicEnabled = enabled
        micToggleButton.setImage(
            UIImage(named: enabled ? "video_mic" : "video_mic_off"),
            for: .normal
        )
        captureSession.connections.forEach { connection in
            guard connection.inputPorts.contains(where: { $0.mediaType == .audio }) else { return }
            connection.isEnabled = enabled
        }
    }

    // MARK: - Actions

    @objc private func didTapSwitchCamera() {
        switchCamera()
    }

    @objc private func didTapToggleVideo() {
        updateVideoEnabled(!isVideoEnabled)
    }

    @objc private func didTapToggleMic() {
        updateMicEnabled(!isMicEnabled)
    }

    @objc private func didTapEndCall() {
        navigationController?.popViewController(animated: true)
    }
}

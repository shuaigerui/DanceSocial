//
//  DS_ContactVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/29.
//

import UIKit
import Toast_Swift

class DS_ContactVC: DS_SecondaryVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 24
        static let navBarHeight: CGFloat = 44
        static let accentColor = UIColor(red: 232 / 255, green: 148 / 255, blue: 77 / 255, alpha: 1)
    }

    static let supportEmail = "Xixifeadback@gmail.com"

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
        label.text = "Contact Us"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private let iconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 56, weight: .medium)
        let image = UIImage(systemName: "envelope.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = Layout.accentColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "If you have questions, feedback, or need assistance, please contact us by email."
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let emailCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.12, alpha: 1)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        return view
    }()

    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = Self.supportEmail
        label.textColor = Layout.accentColor
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSendEmail))
        label.addGestureRecognizer(tap)
        return label
    }()

    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Copy Email", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(white: 0.2, alpha: 1)
        button.layer.cornerRadius = 26
        button.addTarget(self, action: #selector(didTapCopyEmail), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(navBarView)
        view.addSubview(iconImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(emailCardView)
        view.addSubview(copyButton)

        navBarView.addSubview(backButton)
        navBarView.addSubview(titleLabel)

        emailCardView.addSubview(emailTitleLabel)
        emailCardView.addSubview(emailLabel)

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

        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(72)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        emailCardView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        emailTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }

        copyButton.snp.makeConstraints { make in
            make.top.equalTo(emailCardView.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(52)
        }
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapCopyEmail() {
        UIPasteboard.general.string = Self.supportEmail
        view.makeToast("Email copied")
    }

    @objc private func didTapSendEmail() {
        let encoded = Self.supportEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? Self.supportEmail
        guard let url = URL(string: "mailto:\(encoded)"),
              UIApplication.shared.canOpenURL(url) else {
            view.makeToast("Unable to open Mail app")
            return
        }
        UIApplication.shared.open(url)
    }
}

//
//  DS_SetupVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_SetupVC: DS_SecondaryVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let navBarHeight: CGFloat = 44
        static let optionSpacing: CGFloat = 12
        static let optionAspect: CGFloat = 201.0 / 1029.0
        static let confirmAspect: CGFloat = 192.0 / 801.0
    }

    private let optionImageNames = [
        "setup_contact",
        "setup_policy",
        "setup_guide",
        "setup_out",
        "setup_del"
    ]

    private let navBarView: UIView = {
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
        label.text = "set up"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private let optionsContainerView = UIView()

    private lazy var optionsStackView: UIStackView = {
        let imageViews = optionImageNames.map { name -> UIImageView in
            let imageView = UIImageView(image: UIImage(named: name))
            imageView.contentMode = .scaleToFill
            imageView.isUserInteractionEnabled = true
            return imageView
        }
        let stack = UIStackView(arrangedSubviews: imageViews)
        stack.axis = .vertical
        stack.spacing = Layout.optionSpacing
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
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
        setupOptionRowConstraints()
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(navBarView)
        view.addSubview(optionsContainerView)
        view.addSubview(confirmButton)

        navBarView.addSubview(backButton)
        navBarView.addSubview(titleLabel)

        optionsContainerView.addSubview(optionsStackView)

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

        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.height.equalTo(confirmButton.snp.width).multipliedBy(Layout.confirmAspect)
        }

        optionsContainerView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.lessThanOrEqualTo(confirmButton.snp.top).offset(-24)
        }

        optionsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupOptionRowConstraints() {
        optionsStackView.arrangedSubviews.forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(view.snp.width).multipliedBy(Layout.optionAspect)
            }
        }
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapConfirm() {
        navigationController?.popViewController(animated: true)
    }
}

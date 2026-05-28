//
//  DS_ReportVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

enum DS_ReportOption: Int, CaseIterable {
    case pornographic
    case verbalViolence
    case religiousDiscrimination
    case contentError
    case genderDiscrimination
    case blacklist

    var imageName: String {
        switch self {
        case .pornographic: return "report_porn"
        case .verbalViolence: return "report_verbal"
        case .religiousDiscrimination: return "report_relig"
        case .contentError: return "report_content"
        case .genderDiscrimination: return "report_gender"
        case .blacklist: return "report_black"
        }
    }
}

class DS_ReportVC: DS_SecondaryVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let navBarHeight: CGFloat = 44
        static let optionSpacing: CGFloat = 12
        static let optionAspect: CGFloat = 201.0 / 1029.0
    }

    private var selectedOption: DS_ReportOption?

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
        label.text = "Report"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.optionSpacing
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private lazy var optionButtons: [UIButton] = DS_ReportOption.allCases.map { option in
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: option.imageName), for: .normal)
        button.tag = option.rawValue
        button.addTarget(self, action: #selector(didTapOption(_:)), for: .touchUpInside)
        return button
    }

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
        setupOptionConstraints()
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(navBarView)
        view.addSubview(scrollView)
        view.addSubview(confirmButton)

        navBarView.addSubview(backButton)
        navBarView.addSubview(titleLabel)

        scrollView.addSubview(optionsStackView)
        optionButtons.forEach { optionsStackView.addArrangedSubview($0) }

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
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.height.equalTo(64)
            make.width.equalTo(267)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(confirmButton.snp.top).offset(-24)
        }

        optionsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
    }

    private func setupOptionConstraints() {
        optionButtons.forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(button.snp.width).multipliedBy(Layout.optionAspect)
            }
        }
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapOption(_ sender: UIButton) {
        guard let option = DS_ReportOption(rawValue: sender.tag) else { return }

        if option == .blacklist {
            navigationController?.pushViewController(DS_BlackListVC(), animated: true)
            return
        }

        selectedOption = option
        optionButtons.forEach { $0.alpha = $0 === sender ? 1 : 0.65 }
    }

    @objc private func didTapConfirm() {
        // TODO: submit selectedOption report
        navigationController?.popViewController(animated: true)
    }
}

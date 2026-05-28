//
//  DS_SetupVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

enum DS_SetupOption: Int, CaseIterable {
    case contact
    case policy
    case blacklist
    case guide
    case signOut
    case deleteAccount

    var imageName: String {
        switch self {
        case .contact: return "setup_contact"
        case .policy: return "setup_policy"
        case .blacklist: return "setup_black"
        case .guide: return "setup_guide"
        case .signOut: return "setup_out"
        case .deleteAccount: return "setup_del"
        }
    }
}

class DS_SetupVC: DS_SecondaryVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let navBarHeight: CGFloat = 44
        static let optionSpacing: CGFloat = 12
        static let optionRowHeight: CGFloat = 67
    }

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
        label.text = "set up"
        label.textColor = .white
        label.font = UIFont.italicSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private let optionsContainerView = UIView()

    private lazy var optionButtons: [UIButton] = DS_SetupOption.allCases.map { option in
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: option.imageName), for: .normal)
        button.tag = option.rawValue
        button.addTarget(self, action: #selector(didTapOption(_:)), for: .touchUpInside)
        return button
    }

    private lazy var optionsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: optionButtons)
        stack.axis = .vertical
        stack.spacing = Layout.optionSpacing
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
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

        optionsContainerView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-24)
        }

        optionsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupOptionRowConstraints() {
        optionButtons.forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(Layout.optionRowHeight)
            }
        }
    }

    @objc private func didTapOption(_ sender: UIButton) {
        guard let option = DS_SetupOption(rawValue: sender.tag) else { return }
        switch option {
            case .blacklist:
                self.navigationController?.pushViewController(DS_BlackListVC(), animated: true)
//            case .signOut:
//                // 退出登录逻辑
            default:
                break
        }
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

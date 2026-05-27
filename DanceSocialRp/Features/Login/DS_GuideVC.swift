//
//  DS_GuideVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_GuideVC: DS_BaseVC {

    private enum Layout {
        static let backgroundImageNames = ["guide_1", "guide_2", "guide_3"]
        static let nextButtonWidth: CGFloat = 267
        static let nextButtonHeight: CGFloat = 64
    }

    private var currentPageIndex = 0

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "login_next"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.accessibilityLabel = "Next"
        button.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showPage(at: currentPageIndex, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(backgroundImageView)
        view.addSubview(nextButton)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.width.equalTo(Layout.nextButtonWidth)
            make.height.equalTo(Layout.nextButtonHeight)
        }
    }

    private func showPage(at index: Int, animated: Bool) {
        guard Layout.backgroundImageNames.indices.contains(index) else { return }

        let image = UIImage(named: Layout.backgroundImageNames[index])
        guard animated else {
            backgroundImageView.image = image
            return
        }

        UIView.transition(
            with: backgroundImageView,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) {
            self.backgroundImageView.image = image
        }
    }

    @objc private func didTapNext() {
        if currentPageIndex < Layout.backgroundImageNames.count - 1 {
            currentPageIndex += 1
            showPage(at: currentPageIndex, animated: true)
            return
        }
        finishGuide()
    }

    private func finishGuide() {
        DS_TabbarVC.switchToMainInterface()
    }
}

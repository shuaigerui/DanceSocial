//
//  DS_TabBar.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

final class DS_TabBar: UITabBar {

    private enum Layout {
        static let cornerRadius: CGFloat = 28
    }

    private let backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isUserInteractionEnabled = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        isTranslucent = false
        insertSubview(backgroundContainerView, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundContainerView.frame = bounds
        backgroundContainerView.layer.cornerRadius = Layout.cornerRadius
        backgroundContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundContainerView.layer.masksToBounds = true

        subviews.forEach { subview in
            guard subview !== backgroundContainerView else { return }
            let className = NSStringFromClass(type(of: subview))
            if className.contains("_UIBarBackground") || className == "_UIBarBackground" {
                subview.isHidden = true
                subview.alpha = 0
            } else {
                subview.isHidden = false
                subview.alpha = 1
            }
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var fittedSize = super.sizeThatFits(size)
        if fittedSize.height < 49 {
            fittedSize.height = 49
        }
        return fittedSize
    }
}

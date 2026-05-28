//
//  DS_PostHeaderView.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_PostHeaderView: UIView {

    var onReleaseTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black

        addSubview(titleView)
        addSubview(topView)
        addSubview(releaseButton)
        
        titleView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
        }
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.trailing.equalToSuperview().offset(-29)
        }
        releaseButton.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(53)
            make.trailing.leading.equalToSuperview().inset(16)
        }
    }
    
    private let titleView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "post_title"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let topView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "post_icon"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var releaseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "post_release"), for: .normal)
        button.addTarget(self, action: #selector(didTapRelease), for: .touchUpInside)
        return button
    }()

    @objc private func didTapRelease() {
        onReleaseTapped?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

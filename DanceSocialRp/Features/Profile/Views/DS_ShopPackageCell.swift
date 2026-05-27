//
//  DS_ShopPackageCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

struct DS_ShopPackageItem: Hashable {
    let id: Int
    let amount: Int
}

final class DS_ShopPackageCell: UICollectionViewCell {

    static let reuseIdentifier = "DS_ShopPackageCell"

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: DS_ShopPackageItem, isSelected: Bool) {
        let imageName = isSelected ? "shop_bg_sel" : "shop_bg"
        backgroundImageView.image = UIImage(named: imageName)
    }
}

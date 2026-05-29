//
//  DS_ShopPackageCell.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

final class DS_ShopPackageCell: UICollectionViewCell {

    static let reuseIdentifier = "DS_ShopPackageCell"

    private enum Layout {
        /// 文字起始位置，避开 shop_bg 左侧星星
        static let textLeading: CGFloat = 58
    }

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private let diamondsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#D0A6FF")
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .right
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(diamondsLabel)
        contentView.addSubview(priceLabel)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        diamondsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-30)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(diamondsLabel.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: DS_ShopPackageItem, isSelected: Bool, storePrice: String?) {
        let imageName = isSelected ? "shop_bg_sel" : "shop_bg"
        backgroundImageView.image = UIImage(named: imageName)
        diamondsLabel.text = item.diamondsText
        priceLabel.text = storePrice ?? item.priceText
    }
}

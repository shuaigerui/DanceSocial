//
//  DS_EmptyView.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/29.
//

import UIKit

class DS_EmptyView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(emptyView)
        addSubview(emptyLabel)
        
        emptyView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.height.equalTo(194)
        }
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyView.snp.bottom).offset(17)
            make.bottom.equalToSuperview()
        }
    }
    
    private let emptyView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = UIImage(named: "common_empty")
        return v
    }()
    private let emptyLabel: UILabel = {
        let v = UILabel()
        v.text = "No data available"
        v.textColor = UIColor(hex: "#666666")
        v.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return v
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class SS_EmptyTableCell: UITableViewCell {

    static let reuseIdentifier = "SS_EmptyTableCell"
    
    private lazy var emptyView = DS_EmptyView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        contentView.addSubview(emptyView)

        emptyView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(85)
            make.bottom.equalToSuperview().offset(85)
        }
    }
}

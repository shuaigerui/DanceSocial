//
//  DS_LiveHeaderReusableView.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

final class DS_LiveHeaderReusableView: UICollectionReusableView {

    static let reuseIdentifier = "DS_LiveHeaderReusableView"

    private weak var embeddedHeaderView: DS_LiveHeaderView?

    func embed(_ headerView: DS_LiveHeaderView) {
        guard embeddedHeaderView !== headerView else { return }

        embeddedHeaderView?.removeFromSuperview()
        embeddedHeaderView = headerView

        addSubview(headerView)
        headerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        embeddedHeaderView?.removeFromSuperview()
        embeddedHeaderView = nil
    }
}

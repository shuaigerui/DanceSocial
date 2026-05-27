//
//  DS_HomeHeaderReusableView.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

final class DS_HomeHeaderReusableView: UICollectionReusableView {

    static let reuseIdentifier = "DS_HomeHeaderReusableView"

    private weak var embeddedHeaderView: DS_HomeHeaderView?

    func embed(_ headerView: DS_HomeHeaderView) {
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

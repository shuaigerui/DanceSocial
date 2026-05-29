//
//  DS_BaseVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        // 隐藏导航栏（整个导航栏会消失）
        navigationController?.navigationBar.isHidden = true
    }

}

extension UIViewController {

    /// 仅互相关注可进入聊天/视频；未满足时系统弹窗提示
    @discardableResult
    func ds_guardMutualFollowForChat(peerUserId: String) -> Bool {
        guard !peerUserId.isEmpty else { return false }
        if DS_CurrentUser.shared.isMutualFollow(with: peerUserId) {
            return true
        }
        let alert = UIAlertController(
            title: nil,
            message: "You must be friends to chat.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        return false
    }

    /// 拉黑确认弹窗：隐藏对方全部动态并清除私信记录
    func ds_presentBlacklistConfirmation(
        peerUserId: String,
        peerName: String,
        onConfirmBlock: @escaping () -> Void
    ) {
        guard !peerUserId.isEmpty else { return }

        let displayName = peerName.isEmpty ? "this user" : peerName
        let alert = UIAlertController(
            title: "Block this user?",
            message: "You won't see any posts from \(displayName). Your chat history with this user will be cleared.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { _ in
            DS_CurrentUser.shared.blacklistUser(userId: peerUserId)
            onConfirmBlock()
        })
        present(alert, animated: true)
    }
}

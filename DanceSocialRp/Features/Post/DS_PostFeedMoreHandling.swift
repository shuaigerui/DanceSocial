//
//  DS_PostFeedMoreHandling.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

extension UIViewController {

    /// 动态更多：自己的帖子确认删除，他人帖子进入举报页
    func handlePostMoreTapped(post: DS_PostModel, onDeleted: @escaping () -> Void) {
        if post.userId == DS_CurrentUser.shared.user?.userId {
            presentDeletePostConfirmation(postId: post.postId, onDeleted: onDeleted)
        } else {
            navigationController?.pushViewController(DS_ReportVC(postId: post.postId), animated: true)
        }
    }

    private func presentDeletePostConfirmation(postId: String, onDeleted: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Delete This Moment?",
            message: "This post will be permanently removed and can't be restored.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            guard DS_CurrentUser.shared.deletePost(postId: postId) else { return }
            onDeleted()
        })
        present(alert, animated: true)
    }
}

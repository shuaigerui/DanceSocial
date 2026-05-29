//
//  DS_PostCommentModel.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import Foundation

/// 动态评论
struct DS_PostCommentModel: Codable {

    let commentId: String
    let userId: String
    let userName: String
    let avatarUrl: String?
    let content: String
    /// 发布时间（Unix 时间戳）
    let createdAt: TimeInterval

    init(
        commentId: String,
        userId: String,
        userName: String,
        avatarUrl: String? = nil,
        content: String,
        createdAt: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.commentId = commentId
        self.userId = userId
        self.userName = userName
        self.avatarUrl = avatarUrl
        self.content = content
        self.createdAt = createdAt
    }
}

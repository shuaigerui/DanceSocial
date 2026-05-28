//
//  DS_PostModel.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import Foundation

/// 动态媒体类型：每条动态最多一种，且只能有一个图片或一个视频
enum DS_PostMediaType: String, Codable {
    case image
    case video
}

struct DS_PostModel: Codable {

    let postId: String
    let userId: String
    let userName: String
    let avatarUrl: String?
    let content: String
    let mediaType: DS_PostMediaType?
    /// 图片地址，或视频文件地址
    let mediaUrl: String?
    /// 视频封面（仅 `mediaType == .video` 时使用）
    let videoCoverUrl: String?

    var hasMedia: Bool {
        mediaType != nil && mediaUrl != nil
    }

    var isVideo: Bool {
        mediaType == .video
    }

    var isImage: Bool {
        mediaType == .image
    }

    /// 列表封面：视频优先用封面图，图片用 mediaUrl
    var mediaCoverUrl: String? {
        switch mediaType {
        case .image:
            return mediaUrl
        case .video:
            return videoCoverUrl ?? mediaUrl
        case .none:
            return nil
        }
    }

    init(
        postId: String,
        userId: String,
        userName: String,
        avatarUrl: String? = nil,
        content: String,
        mediaType: DS_PostMediaType? = nil,
        mediaUrl: String? = nil,
        videoCoverUrl: String? = nil
    ) {
        self.postId = postId
        self.userId = userId
        self.userName = userName
        self.avatarUrl = avatarUrl
        self.content = content
        self.mediaType = mediaType
        self.mediaUrl = mediaUrl
        self.videoCoverUrl = videoCoverUrl
    }
}

extension DS_PostModel {

    /// 创建仅文字动态
    static func text(
        postId: String,
        userId: String,
        userName: String,
        avatarUrl: String? = nil,
        content: String
    ) -> DS_PostModel {
        DS_PostModel(
            postId: postId,
            userId: userId,
            userName: userName,
            avatarUrl: avatarUrl,
            content: content
        )
    }

    /// 创建图片动态（单图）
    static func image(
        postId: String,
        userId: String,
        userName: String,
        avatarUrl: String? = nil,
        content: String,
        imageUrl: String
    ) -> DS_PostModel {
        DS_PostModel(
            postId: postId,
            userId: userId,
            userName: userName,
            avatarUrl: avatarUrl,
            content: content,
            mediaType: .image,
            mediaUrl: imageUrl
        )
    }

    /// 创建视频动态（单视频）
    static func video(
        postId: String,
        userId: String,
        userName: String,
        avatarUrl: String? = nil,
        content: String,
        videoUrl: String,
        coverUrl: String? = nil
    ) -> DS_PostModel {
        DS_PostModel(
            postId: postId,
            userId: userId,
            userName: userName,
            avatarUrl: avatarUrl,
            content: content,
            mediaType: .video,
            mediaUrl: videoUrl,
            videoCoverUrl: coverUrl
        )
    }
}

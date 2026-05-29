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
    /// 评论列表
    let comments: [DS_PostCommentModel]

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

    enum CodingKeys: String, CodingKey {
        case postId
        case userId
        case userName
        case avatarUrl
        case content
        case mediaType
        case mediaUrl
        case videoCoverUrl
        case comments
    }

    init(
        postId: String,
        userId: String,
        userName: String,
        avatarUrl: String? = nil,
        content: String,
        mediaType: DS_PostMediaType? = nil,
        mediaUrl: String? = nil,
        videoCoverUrl: String? = nil,
        comments: [DS_PostCommentModel] = []
    ) {
        self.postId = postId
        self.userId = userId
        self.userName = userName
        self.avatarUrl = avatarUrl
        self.content = content
        self.mediaType = mediaType
        self.mediaUrl = mediaUrl
        self.videoCoverUrl = videoCoverUrl
        self.comments = comments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        postId = try container.decode(String.self, forKey: .postId)
        userId = try container.decode(String.self, forKey: .userId)
        userName = try container.decode(String.self, forKey: .userName)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        content = try container.decode(String.self, forKey: .content)
        mediaType = try container.decodeIfPresent(DS_PostMediaType.self, forKey: .mediaType)
        mediaUrl = try container.decodeIfPresent(String.self, forKey: .mediaUrl)
        videoCoverUrl = try container.decodeIfPresent(String.self, forKey: .videoCoverUrl)
        comments = try container.decodeIfPresent([DS_PostCommentModel].self, forKey: .comments) ?? []
    }
}

extension DS_PostModel {

    /// 创建仅文字动态
    static func text(
        postId: String,
        userId: String,
        userName: String,
        avatarUrl: String? = nil,
        content: String,
        comments: [DS_PostCommentModel] = []
    ) -> DS_PostModel {
        DS_PostModel(
            postId: postId,
            userId: userId,
            userName: userName,
            avatarUrl: avatarUrl,
            content: content,
            comments: comments
        )
    }

    /// 创建图片动态（单图）
    static func image(
        postId: String,
        userId: String,
        userName: String,
        avatarUrl: String? = nil,
        content: String,
        imageUrl: String,
        comments: [DS_PostCommentModel] = []
    ) -> DS_PostModel {
        DS_PostModel(
            postId: postId,
            userId: userId,
            userName: userName,
            avatarUrl: avatarUrl,
            content: content,
            mediaType: .image,
            mediaUrl: imageUrl,
            comments: comments
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
        coverUrl: String? = nil,
        comments: [DS_PostCommentModel] = []
    ) -> DS_PostModel {
        DS_PostModel(
            postId: postId,
            userId: userId,
            userName: userName,
            avatarUrl: avatarUrl,
            content: content,
            mediaType: .video,
            mediaUrl: videoUrl,
            videoCoverUrl: coverUrl,
            comments: comments
        )
    }
}

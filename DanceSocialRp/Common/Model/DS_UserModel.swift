//
//  DS_UserModel.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import Foundation

/// 用户 / 个人中心
struct DS_UserModel: Codable {

    let userId: String
    /// 登录账号（邮箱或用户名）
    let account: String
    /// 密码（仅本地登录态保存，接口返回用户资料时通常为空）
    let password: String?
    let userName: String
    let avatarUrl: String?
    let coverUrl: String?
    /// 金币余额
    let goldCoins: Int
    /// 是否已拉黑（黑名单）
    let isBlack: Bool
    /// 是否已关注
    let isFollow: Bool
    /// 用户发布的动态列表（个人中心 release 区域）
    let posts: [DS_PostModel]
    /// 用户创建的聊天室列表
    let createdLiveRooms: [DS_LiveModel]

    init(
        userId: String,
        account: String,
        password: String? = nil,
        userName: String,
        avatarUrl: String? = nil,
        coverUrl: String? = nil,
        goldCoins: Int = 0,
        isBlack: Bool = false,
        isFollow: Bool = false,
        posts: [DS_PostModel] = [],
        createdLiveRooms: [DS_LiveModel] = []
    ) {
        self.userId = userId
        self.account = account
        self.password = password
        self.userName = userName
        self.avatarUrl = avatarUrl
        self.coverUrl = coverUrl
        self.goldCoins = goldCoins
        self.isBlack = isBlack
        self.isFollow = isFollow
        self.posts = posts
        self.createdLiveRooms = createdLiveRooms
    }
}

extension DS_UserModel {

    /// 当前登录用户个人中心预览数据
    static let preview = DS_UserModel(
        userId: "u_001",
        account: "marceline@example.com",
        password: nil,
        userName: "Marceline",
        avatarUrl: nil,
        coverUrl: nil,
        goldCoins: 123123,
        isBlack: false,
        isFollow: false,
        posts: [
            DS_PostModel(
                postId: "p_001",
                userId: "u_001",
                userName: "Trending",
                content: "Keep your promise to a winter snowfall and encounter freedom on the ski slopes.",
                mediaType: .video,
                mediaUrl: nil,
                videoCoverUrl: nil
            )
        ],
        createdLiveRooms: [
            DS_LiveModel(
                roomId: "r_001",
                title: "Dance Power",
                coverUrl: "",
                hostUserId: "u_001",
                hostUserName: "Marceline"
            )
        ]
    )

    /// 他人主页（不含账号密码）
    static func person(
        userId: String,
        userName: String,
        avatarUrl: String? = nil,
        coverUrl: String? = nil,
        isBlack: Bool = false,
        isFollow: Bool = false,
        posts: [DS_PostModel] = [],
        createdLiveRooms: [DS_LiveModel] = []
    ) -> DS_UserModel {
        DS_UserModel(
            userId: userId,
            account: "",
            password: nil,
            userName: userName,
            avatarUrl: avatarUrl,
            coverUrl: coverUrl,
            goldCoins: 0,
            isBlack: isBlack,
            isFollow: isFollow,
            posts: posts,
            createdLiveRooms: createdLiveRooms
        )
    }

    /// 注册 / 登录成功后构建本地用户
    static func session(
        userId: String,
        account: String,
        password: String,
        userName: String,
        avatarUrl: String? = nil,
        coverUrl: String? = nil,
        goldCoins: Int = 0,
        posts: [DS_PostModel] = [],
        createdLiveRooms: [DS_LiveModel] = []
    ) -> DS_UserModel {
        DS_UserModel(
            userId: userId,
            account: account,
            password: password,
            userName: userName,
            avatarUrl: avatarUrl,
            coverUrl: coverUrl,
            goldCoins: goldCoins,
            posts: posts,
            createdLiveRooms: createdLiveRooms
        )
    }
}

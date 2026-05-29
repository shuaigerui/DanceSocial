//
//  DS_CurrentUser.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import UIKit

/// 当前登录用户单例
final class DS_CurrentUser {

    static let shared = DS_CurrentUser()

    /// 审核 / 演示测试账号（使用 UserData 第一个用户 Marceline 的完整数据）
    static let reviewAccount = "test@gmail.com"
    static let reviewPassword = "123456"

    /// 测试账号 userId（Marceline）
    static let testUserId = "u_001"

    private enum StorageKey {
        static let registeredUsers = "ds_registered_users"
        static let loggedInUserId = "ds_logged_in_user_id"
        static let followByUserId = "ds_follow_by_user_id"
        static let postExtraComments = "ds_post_extra_comments"
        static let followEdges = "ds_follow_edges"
        static let followGraphSeeded = "ds_follow_graph_seeded_v1"
        static let hiddenPostIds = "ds_hidden_post_ids"
        static let blacklistedUserIds = "ds_blacklisted_user_ids"
    }

    private(set) var user: DS_UserModel?

    var isLoggedIn: Bool {
        user != nil
    }

    private var registeredUsers: [DS_UserModel] = []
    private var followByUserId: [String: Bool] = [:]
    /// followerId|followingId，表示 follower 关注了 following
    private var followEdges: Set<String> = []
    /// 用户发送的评论，按 postId 持久化（重启后保留）
    private var postExtraComments: [String: [DS_PostCommentModel]] = [:]
    /// 当前用户举报后隐藏的动态 postId
    private var hiddenPostIds: Set<String> = []
    /// 当前用户拉黑的用户 userId
    private var blacklistedUserIds: Set<String> = []

    private init() {
        loadRegisteredUsers()
        loadPostExtraComments()
        loadFollowStates()
        loadFollowGraph()
        restoreSessionIfNeeded()
    }

    // MARK: - Sign in

    @discardableResult
    func signIn(account: String, password: String) -> Bool {
        let email = account.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !email.isEmpty, !password.isEmpty else { return false }

        if email == Self.reviewAccount.lowercased(), password == Self.reviewPassword {
            let base = UserData.users[0]
            let user = signInUser(for: base)
            configure(with: user)
            enterMainInterface()
            return true
        }

        if let preset = UserData.users.first(where: {
            $0.account.lowercased() == email && $0.password == password
        }) {
            configure(with: signInUser(for: preset))
            enterMainInterface()
            return true
        }

        if let registered = registeredUsers.first(where: {
            $0.account.lowercased() == email && $0.password == password
        }) {
            configure(with: registered)
            enterMainInterface()
            return true
        }

        return false
    }

    /// 注册 / Apple 登录完善资料后设置当前用户
    func configure(with user: DS_UserModel, saveToRegisteredList: Bool = false) {
        let normalized = UserData.migrateUserMediaPaths(user)
        self.user = normalized
        UserDefaults.standard.set(normalized.userId, forKey: StorageKey.loggedInUserId)
        loadHiddenPostIds(for: normalized.userId)
        loadBlacklistedUserIds(for: normalized.userId)

        if saveToRegisteredList {
            upsertRegisteredUser(normalized)
        }
    }

    func signOut() {
        user = nil
        hiddenPostIds = []
        blacklistedUserIds = []
        UserDefaults.standard.removeObject(forKey: StorageKey.loggedInUserId)
    }

    func enterMainInterface(animated: Bool = true) {
        DS_TabbarVC.switchToMainInterface(animated: animated)
    }

    // MARK: - Registration

    /// 创建账号完成后构建用户（头像保存到沙盒）
    func registerUser(
        account: String,
        password: String,
        userName: String,
        avatarImage: UIImage?
    ) -> DS_UserModel {
        let userId = "u_reg_\(UUID().uuidString.prefix(8))"
        let avatarPath = saveAvatarImage(avatarImage, userId: userId)

        let newUser = DS_UserModel(
            userId: userId,
            account: account.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            userName: userName.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarUrl: avatarPath,
            coverUrl: nil,
            goldCoins: 0,
            posts: [],
            createdLiveRooms: []
        )

        configure(with: newUser, saveToRegisteredList: true)
        return newUser
    }

    /// Apple 登录完善资料
    func registerAppleUser(
        userName: String,
        avatarImage: UIImage?
    ) -> DS_UserModel {
        let userId = "u_apple_\(UUID().uuidString.prefix(8))"
        let account = "\(userId)@apple.local"
        let avatarPath = saveAvatarImage(avatarImage, userId: userId)

        let newUser = DS_UserModel(
            userId: userId,
            account: account,
            password: nil,
            userName: userName.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarUrl: avatarPath,
            coverUrl: nil,
            goldCoins: 0,
            posts: [],
            createdLiveRooms: []
        )

        configure(with: newUser, saveToRegisteredList: true)
        return newUser
    }

    // MARK: - Post

    /// 发布动态并保存到当前用户本地数据
    @discardableResult
    func addPost(
        content: String,
        mediaType: DS_PostMediaType,
        image: UIImage?,
        videoSourceURL: URL?
    ) -> Bool {
        guard let current = user else { return false }

        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return false }

        let postId = "p_\(current.userId)_\(UUID().uuidString.prefix(8))"
        let mediaUrl: String?
        var videoCoverUrl: String?

        switch mediaType {
        case .image:
            guard let image, let path = savePostImage(image, postId: postId) else { return false }
            mediaUrl = path
        case .video:
            guard let videoSourceURL, let path = savePostVideo(from: videoSourceURL, postId: postId) else {
                return false
            }
            mediaUrl = path
            videoCoverUrl = savePostVideoCover(forVideoAt: path, postId: postId)
        }

        let post = DS_PostModel(
            postId: postId,
            userId: current.userId,
            userName: current.userName,
            avatarUrl: current.avatarUrl,
            content: trimmedContent,
            mediaType: mediaType,
            mediaUrl: mediaUrl,
            videoCoverUrl: videoCoverUrl
        )

        let updatedUser = DS_UserModel(
            userId: current.userId,
            account: current.account,
            password: current.password,
            userName: current.userName,
            avatarUrl: current.avatarUrl,
            coverUrl: current.coverUrl,
            goldCoins: current.goldCoins,
            isBlack: current.isBlack,
            isFollow: current.isFollow,
            posts: current.posts + [post],
            createdLiveRooms: current.createdLiveRooms
        )

        configure(with: updatedUser, saveToRegisteredList: true)
        return true
    }

    /// 动态广场：预设帖子 + 本地覆盖，并合并用户发送的评论
    func allFeedPosts() -> [DS_PostModel] {
        var postsById: [String: DS_PostModel] = [:]
        for post in UserData.users.flatMap(\.posts) {
            postsById[post.postId] = postWithMergedComments(post)
        }
        for registered in registeredUsers {
            for post in registered.posts {
                postsById[post.postId] = postWithMergedComments(post)
            }
        }
        return filterVisiblePosts(Array(postsById.values))
    }

    /// 举报后隐藏动态（仅对当前登录用户生效，本地持久化）
    func hidePost(postId: String) {
        guard let current = user, !postId.isEmpty else { return }
        hiddenPostIds.insert(postId)
        saveHiddenPostIds(for: current.userId)
    }

    func isPostHidden(postId: String) -> Bool {
        hiddenPostIds.contains(postId)
    }

    func filterVisiblePosts(_ posts: [DS_PostModel]) -> [DS_PostModel] {
        posts.filter {
            !hiddenPostIds.contains($0.postId) && !blacklistedUserIds.contains($0.userId)
        }
    }

    func isUserBlacklisted(userId: String) -> Bool {
        blacklistedUserIds.contains(userId)
    }

    /// 拉黑用户：隐藏其全部动态并清除私信记录
    func blacklistUser(userId: String) {
        guard let current = user, !userId.isEmpty, userId != current.userId else { return }
        blacklistedUserIds.insert(userId)
        saveBlacklistedUserIds(for: current.userId)
        DS_ChatStore.deleteConversation(currentUserId: current.userId, peerUserId: userId)
    }

    func unblacklistUser(userId: String) {
        guard let current = user, !userId.isEmpty else { return }
        blacklistedUserIds.remove(userId)
        saveBlacklistedUserIds(for: current.userId)
    }

    func blacklistItems() -> [DS_BlackListItem] {
        blacklistedUserIds.sorted().compactMap { userId in
            guard let user = UserData.resolvedUser(userId: userId) else { return nil }
            return DS_BlackListItem(
                userId: user.userId,
                avatarImageName: user.avatarUrl,
                userName: user.userName
            )
        }
    }

    /// 查找任意用户下的一条动态（预设 + 本地注册数据 + 用户评论）
    func post(postId: String) -> DS_PostModel? {
        guard let raw = rawPost(postId: postId) else { return nil }
        return postWithMergedComments(raw)
    }

    /// 为指定动态添加评论并持久化到本地
    @discardableResult
    func addComment(toPostId postId: String, content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let current = user else { return false }
        guard let targetPost = post(postId: postId) else { return false }

        let comment = DS_PostCommentModel(
            commentId: "c_\(UUID().uuidString.prefix(8))",
            userId: current.userId,
            userName: current.userName,
            avatarUrl: current.avatarUrl,
            content: trimmed
        )

        var extra = postExtraComments[postId] ?? []
        extra.append(comment)
        postExtraComments[postId] = extra
        savePostExtraComments()

        let updatedPost = DS_PostModel(
            postId: targetPost.postId,
            userId: targetPost.userId,
            userName: targetPost.userName,
            avatarUrl: targetPost.avatarUrl,
            content: targetPost.content,
            mediaType: targetPost.mediaType,
            mediaUrl: targetPost.mediaUrl,
            videoCoverUrl: targetPost.videoCoverUrl,
            comments: targetPost.comments + [comment]
        )

        replacePost(updatedPost, ownerUserId: targetPost.userId)
        return true
    }

    private func rawPost(postId: String) -> DS_PostModel? {
        for registered in registeredUsers {
            if let post = registered.posts.first(where: { $0.postId == postId }) {
                return post
            }
        }
        if let user, let post = user.posts.first(where: { $0.postId == postId }) {
            return post
        }
        return UserData.users.lazy.flatMap(\.posts).first { $0.postId == postId }
    }

    private func mergedComments(for postId: String, base: [DS_PostCommentModel]) -> [DS_PostCommentModel] {
        let extra = postExtraComments[postId] ?? []
        var byId = Dictionary(uniqueKeysWithValues: base.map { ($0.commentId, $0) })
        for comment in extra {
            byId[comment.commentId] = comment
        }
        return byId.values.sorted { $0.createdAt < $1.createdAt }
    }

    private func postWithMergedComments(_ post: DS_PostModel) -> DS_PostModel {
        DS_PostModel(
            postId: post.postId,
            userId: post.userId,
            userName: post.userName,
            avatarUrl: post.avatarUrl,
            content: post.content,
            mediaType: post.mediaType,
            mediaUrl: post.mediaUrl,
            videoCoverUrl: post.videoCoverUrl,
            comments: mergedComments(for: post.postId, base: post.comments)
        )
    }

    private func userWithMergedPostComments(_ user: DS_UserModel) -> DS_UserModel {
        let posts = user.posts.map(postWithMergedComments)
        return DS_UserModel(
            userId: user.userId,
            account: user.account,
            password: user.password,
            userName: user.userName,
            avatarUrl: user.avatarUrl,
            coverUrl: user.coverUrl,
            goldCoins: user.goldCoins,
            isBlack: user.isBlack,
            isFollow: user.isFollow,
            posts: posts,
            createdLiveRooms: user.createdLiveRooms
        )
    }

    @discardableResult
    private func replacePost(_ post: DS_PostModel, ownerUserId: String) -> Bool {
        if let index = registeredUsers.firstIndex(where: { $0.userId == ownerUserId }) {
            var owner = registeredUsers[index]
            guard let postIndex = owner.posts.firstIndex(where: { $0.postId == post.postId }) else {
                return false
            }
            var posts = owner.posts
            posts[postIndex] = post
            owner = user(owner, posts: posts)
            registeredUsers[index] = owner
            saveRegisteredUsers()
            if user?.userId == ownerUserId {
                user = owner
            }
            return true
        }

        guard let preset = UserData.user(userId: ownerUserId),
              preset.posts.contains(where: { $0.postId == post.postId }) else {
            return false
        }

        var owner = UserData.migrateUserMediaPaths(preset)
        guard let postIndex = owner.posts.firstIndex(where: { $0.postId == post.postId }) else {
            return false
        }
        var posts = owner.posts
        posts[postIndex] = post
        owner = user(owner, posts: posts)
        upsertRegisteredUser(owner)
        if user?.userId == ownerUserId {
            user = owner
        }
        return true
    }

    private func user(_ user: DS_UserModel, posts: [DS_PostModel]) -> DS_UserModel {
        DS_UserModel(
            userId: user.userId,
            account: user.account,
            password: user.password,
            userName: user.userName,
            avatarUrl: user.avatarUrl,
            coverUrl: user.coverUrl,
            goldCoins: user.goldCoins,
            isBlack: user.isBlack,
            isFollow: user.isFollow,
            posts: posts,
            createdLiveRooms: user.createdLiveRooms
        )
    }

    /// 删除当前用户的一条动态并同步到本地
    @discardableResult
    func deletePost(postId: String) -> Bool {
        guard let current = user,
              current.posts.contains(where: { $0.postId == postId }) else {
            return false
        }

        let removedPosts = current.posts.filter { $0.postId == postId }
        removedPosts.forEach(removePostMediaFiles(for:))

        let updatedUser = DS_UserModel(
            userId: current.userId,
            account: current.account,
            password: current.password,
            userName: current.userName,
            avatarUrl: current.avatarUrl,
            coverUrl: current.coverUrl,
            goldCoins: current.goldCoins,
            isBlack: current.isBlack,
            isFollow: current.isFollow,
            posts: current.posts.filter { $0.postId != postId },
            createdLiveRooms: current.createdLiveRooms
        )

        configure(with: updatedUser, saveToRegisteredList: true)
        return true
    }

    // MARK: - Live room

    /// 创建聊天室并保存到当前用户本地数据
    @discardableResult
    func addCreatedLiveRoom(title: String, coverImage: UIImage) -> Bool {
        guard let current = user else { return false }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return false }

        let roomId = "r_\(current.userId)_\(UUID().uuidString.prefix(8))"
        guard let coverPath = saveLiveRoomCover(coverImage, roomId: roomId) else { return false }

        let memberAvatars = current.avatarUrl.map { [$0] } ?? []
        let room = DS_LiveModel(
            roomId: roomId,
            title: trimmedTitle,
            coverUrl: coverPath,
            hostUserId: current.userId,
            hostUserName: current.userName,
            hostAvatarUrl: current.avatarUrl,
            memberAvatarUrls: memberAvatars
        )

        let updatedUser = DS_UserModel(
            userId: current.userId,
            account: current.account,
            password: current.password,
            userName: current.userName,
            avatarUrl: current.avatarUrl,
            coverUrl: current.coverUrl,
            goldCoins: current.goldCoins,
            isBlack: current.isBlack,
            isFollow: current.isFollow,
            posts: current.posts,
            createdLiveRooms: current.createdLiveRooms + [room]
        )

        configure(with: updatedUser, saveToRegisteredList: true)
        return true
    }

    // MARK: - Profile

    /// 更新当前用户昵称与头像（保存到本地）
    @discardableResult
    func updateProfile(userName: String?, avatarImage: UIImage?) -> Bool {
        guard let current = user else { return false }

        let trimmedName = userName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let finalName = trimmedName.isEmpty ? current.userName : trimmedName

        var avatarPath = current.avatarUrl
        if let avatarImage, let path = saveAvatarImage(avatarImage, userId: current.userId) {
            avatarPath = path
        }

        let updatedPosts = current.posts.map { post in
            DS_PostModel(
                postId: post.postId,
                userId: post.userId,
                userName: finalName,
                avatarUrl: avatarPath,
                content: post.content,
                mediaType: post.mediaType,
                mediaUrl: post.mediaUrl,
                videoCoverUrl: post.videoCoverUrl,
                comments: post.comments
            )
        }

        let updatedRooms = current.createdLiveRooms.map { room in
            DS_LiveModel(
                roomId: room.roomId,
                title: room.title,
                coverUrl: room.coverUrl,
                hostUserId: room.hostUserId,
                hostUserName: finalName,
                hostAvatarUrl: avatarPath,
                memberAvatarUrls: room.memberAvatarUrls
            )
        }

        let updatedUser = DS_UserModel(
            userId: current.userId,
            account: current.account,
            password: current.password,
            userName: finalName,
            avatarUrl: avatarPath,
            coverUrl: current.coverUrl,
            goldCoins: current.goldCoins,
            isBlack: current.isBlack,
            isFollow: current.isFollow,
            posts: updatedPosts,
            createdLiveRooms: updatedRooms
        )

        configure(with: updatedUser, saveToRegisteredList: true)
        return true
    }

    /// 按 userId 获取用户（优先本地已保存的注册/更新数据）
    func resolvedUser(userId: String) -> DS_UserModel? {
        let base: DS_UserModel?
        if let registered = registeredUsers.first(where: { $0.userId == userId }) {
            base = registered
        } else {
            base = UserData.user(userId: userId)
        }
        guard let base else { return nil }
        let merged = UserData.user(userId: userId).map {
            UserData.mergingPresetComments(into: base, preset: $0)
        } ?? base
        return applyingStoredFollowState(to: userWithVisiblePosts(userWithMergedPostComments(merged)))
    }

    private func userWithVisiblePosts(_ user: DS_UserModel) -> DS_UserModel {
        let posts = filterVisiblePosts(user.posts)
        guard posts.count != user.posts.count else { return user }
        return DS_UserModel(
            userId: user.userId,
            account: user.account,
            password: user.password,
            userName: user.userName,
            avatarUrl: user.avatarUrl,
            coverUrl: user.coverUrl,
            goldCoins: user.goldCoins,
            isBlack: user.isBlack,
            isFollow: user.isFollow,
            posts: posts,
            createdLiveRooms: user.createdLiveRooms
        )
    }

    private func hiddenPostIdsKey(for userId: String) -> String {
        "\(StorageKey.hiddenPostIds)_\(userId)"
    }

    private func loadHiddenPostIds(for userId: String) {
        let key = hiddenPostIdsKey(for: userId)
        if let stored = UserDefaults.standard.array(forKey: key) as? [String] {
            hiddenPostIds = Set(stored)
        } else {
            hiddenPostIds = []
        }
    }

    private func saveHiddenPostIds(for userId: String) {
        let key = hiddenPostIdsKey(for: userId)
        UserDefaults.standard.set(Array(hiddenPostIds), forKey: key)
    }

    private func blacklistedUserIdsKey(for userId: String) -> String {
        "\(StorageKey.blacklistedUserIds)_\(userId)"
    }

    private func loadBlacklistedUserIds(for userId: String) {
        let key = blacklistedUserIdsKey(for: userId)
        if let stored = UserDefaults.standard.array(forKey: key) as? [String] {
            blacklistedUserIds = Set(stored)
        } else {
            blacklistedUserIds = []
        }
    }

    private func saveBlacklistedUserIds(for userId: String) {
        let key = blacklistedUserIdsKey(for: userId)
        UserDefaults.standard.set(Array(blacklistedUserIds), forKey: key)
    }

    // MARK: - Follow

    /// 当前用户是否关注了对方
    func isFollowing(userId: String) -> Bool {
        guard let current = user else { return false }
        return follows(followerId: current.userId, followingId: userId)
    }

    /// 是否与对方互相关注
    func isMutualFollow(with userId: String) -> Bool {
        guard let current = user else { return false }
        return follows(followerId: current.userId, followingId: userId)
            && follows(followerId: userId, followingId: current.userId)
    }

    /// 关注了当前用户的用户（Ask 列表）
    func chatAskItems() -> [DS_ChatAskItem] {
        guard let current = user else { return [] }
        return followerUserIds(of: current.userId)
            .filter { !isUserBlacklisted(userId: $0) }
            .compactMap { UserData.resolvedUser(userId: $0) }
            .map { follower in
                DS_ChatAskItem(
                    userId: follower.userId,
                    avatarImageName: follower.avatarUrl,
                    name: follower.userName,
                    isFollowing: isFollowing(userId: follower.userId)
                )
            }
    }

    /// 与当前用户互相关注的用户（Friend 列表）
    func chatFriendItems() -> [DS_ChatFriendItem] {
        guard let current = user else { return [] }
        return followerUserIds(of: current.userId)
            .filter { isMutualFollow(with: $0) && !isUserBlacklisted(userId: $0) }
            .compactMap { UserData.resolvedUser(userId: $0) }
            .map { friend in
                DS_ChatFriendItem(
                    userId: friend.userId,
                    avatarImageName: friend.avatarUrl,
                    name: friend.userName
                )
            }
    }

    /// 切换关注状态并写入本地
    @discardableResult
    func toggleFollow(userId: String, isFollow: Bool) -> Bool {
        guard let current = user else { return false }
        let newValue = !isFollow
        setFollow(followerId: current.userId, followingId: userId, follows: newValue)
        followByUserId[userId] = newValue
        saveFollowStates()

        if let registered = registeredUsers.first(where: { $0.userId == userId }) {
            upsertRegisteredUser(user(registered, isFollow: newValue))
        }
        return newValue
    }

    private func follows(followerId: String, followingId: String) -> Bool {
        followEdges.contains(followEdgeKey(followerId: followerId, followingId: followingId))
    }

    private func setFollow(followerId: String, followingId: String, follows: Bool, persist: Bool = true) {
        let key = followEdgeKey(followerId: followerId, followingId: followingId)
        if follows {
            followEdges.insert(key)
        } else {
            followEdges.remove(key)
        }
        if persist {
            saveFollowGraph()
        }
    }

    private func followEdgeKey(followerId: String, followingId: String) -> String {
        "\(followerId)|\(followingId)"
    }

    private func followerUserIds(of userId: String) -> [String] {
        knownUserIds()
            .filter { $0 != userId && follows(followerId: $0, followingId: userId) }
            .sorted()
    }

    private func knownUserIds() -> [String] {
        var ids = Set(UserData.users.map(\.userId))
        registeredUsers.forEach { ids.insert($0.userId) }
        if let currentId = user?.userId {
            ids.insert(currentId)
        }
        return Array(ids)
    }

    private func loadFollowGraph() {
        if let stored = UserDefaults.standard.array(forKey: StorageKey.followEdges) as? [String] {
            followEdges = Set(stored)
        } else {
            followEdges = []
        }

        guard !UserDefaults.standard.bool(forKey: StorageKey.followGraphSeeded) else { return }
        seedDefaultFollowGraph()
        UserDefaults.standard.set(true, forKey: StorageKey.followGraphSeeded)
    }

    /// 预设：其余 4 个用户均关注测试账号；测试账号关注 Luna、Beach
    private func seedDefaultFollowGraph() {
        let testId = Self.testUserId
        for preset in UserData.users where preset.userId != testId {
            setFollow(followerId: preset.userId, followingId: testId, follows: true, persist: false)
        }
        setFollow(followerId: testId, followingId: "u_002", follows: true, persist: false)
        setFollow(followerId: testId, followingId: "u_003", follows: true, persist: false)

        followByUserId["u_002"] = true
        followByUserId["u_003"] = true
        saveFollowStates()
        saveFollowGraph()
    }

    private func saveFollowGraph() {
        UserDefaults.standard.set(Array(followEdges), forKey: StorageKey.followEdges)
    }

    private func applyingStoredFollowState(to user: DS_UserModel) -> DS_UserModel {
        guard let isFollow = followByUserId[user.userId] else { return user }
        guard user.isFollow != isFollow else { return user }
        return self.user(user, isFollow: isFollow)
    }

    private func user(_ user: DS_UserModel, isFollow: Bool) -> DS_UserModel {
        DS_UserModel(
            userId: user.userId,
            account: user.account,
            password: user.password,
            userName: user.userName,
            avatarUrl: user.avatarUrl,
            coverUrl: user.coverUrl,
            goldCoins: user.goldCoins,
            isBlack: user.isBlack,
            isFollow: isFollow,
            posts: user.posts,
            createdLiveRooms: user.createdLiveRooms
        )
    }

    private func saveFollowStates() {
        UserDefaults.standard.set(followByUserId, forKey: StorageKey.followByUserId)
    }

    private func loadFollowStates() {
        guard let stored = UserDefaults.standard.dictionary(forKey: StorageKey.followByUserId) as? [String: Bool] else {
            followByUserId = [:]
            return
        }
        followByUserId = stored
    }

    // MARK: - Avatar file

    func avatarImage(for user: DS_UserModel) -> UIImage? {
        UserData.image(for: user.avatarUrl)
    }

    @discardableResult
    private func saveAvatarImage(_ image: UIImage?, userId: String) -> String? {
        guard let image,
              let data = image.jpegData(compressionQuality: 0.85) else {
            return nil
        }

        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Avatars", isDirectory: true)

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileURL = directory.appendingPathComponent("\(userId).jpg")
        try? data.write(to: fileURL)
        return UserData.persistableMediaPath(for: fileURL)
    }

    private var postsDirectory: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Posts", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    @discardableResult
    private func savePostImage(_ image: UIImage, postId: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let fileURL = postsDirectory.appendingPathComponent("\(postId).jpg")
        do {
            try data.write(to: fileURL)
            return UserData.persistableMediaPath(for: fileURL)
        } catch {
            return nil
        }
    }

    @discardableResult
    private func savePostVideoCover(forVideoAt videoPath: String, postId: String) -> String? {
        guard let image = DS_VideoThumbnailLoader.thumbnailImage(for: videoPath) else { return nil }
        return savePostImage(image, postId: "\(postId)_cover")
    }

    private func removePostMediaFiles(for post: DS_PostModel) {
        [post.mediaUrl, post.videoCoverUrl].forEach { path in
            guard let path,
                  let url = UserData.resolveMediaFileURL(path: path) else { return }
            try? FileManager.default.removeItem(at: url)
        }
    }

    @discardableResult
    private func savePostVideo(from sourceURL: URL, postId: String) -> String? {
        let fileURL = postsDirectory.appendingPathComponent("\(postId).mp4")
        let fileManager = FileManager.default

        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
            if sourceURL.standardizedFileURL == fileURL.standardizedFileURL {
                return UserData.persistableMediaPath(for: fileURL)
            }
            try fileManager.copyItem(at: sourceURL, to: fileURL)
            if sourceURL.path.contains("/pick_"), fileManager.fileExists(atPath: sourceURL.path) {
                try? fileManager.removeItem(at: sourceURL)
            }
            return UserData.persistableMediaPath(for: fileURL)
        } catch {
            return nil
        }
    }

    @discardableResult
    private func saveLiveRoomCover(_ image: UIImage, roomId: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }

        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LiveRooms", isDirectory: true)

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileURL = directory.appendingPathComponent("\(roomId).jpg")
        do {
            try data.write(to: fileURL)
            return UserData.persistableMediaPath(for: fileURL)
        } catch {
            return nil
        }
    }

    // MARK: - Persistence

    /// 登录预设账号：优先本地副本，并补足预设帖子的固定评论
    private func signInUser(for preset: DS_UserModel) -> DS_UserModel {
        guard let registered = registeredUsers.first(where: { $0.userId == preset.userId }) else {
            return preset
        }
        return UserData.mergingPresetComments(into: registered, preset: preset)
    }

    private func upsertRegisteredUser(_ user: DS_UserModel) {
        if let index = registeredUsers.firstIndex(where: { $0.userId == user.userId }) {
            registeredUsers[index] = user
        } else if let index = registeredUsers.firstIndex(where: { $0.account.lowercased() == user.account.lowercased() }) {
            registeredUsers[index] = user
        } else {
            registeredUsers.append(user)
        }
        saveRegisteredUsers()
    }

    private func saveRegisteredUsers() {
        guard let data = try? JSONEncoder().encode(registeredUsers) else { return }
        UserDefaults.standard.set(data, forKey: StorageKey.registeredUsers)
    }

    private func loadPostExtraComments() {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.postExtraComments),
              let decoded = try? JSONDecoder().decode([String: [DS_PostCommentModel]].self, from: data) else {
            postExtraComments = [:]
            return
        }
        postExtraComments = decoded
    }

    private func savePostExtraComments() {
        guard let data = try? JSONEncoder().encode(postExtraComments) else { return }
        UserDefaults.standard.set(data, forKey: StorageKey.postExtraComments)
    }

    private func loadRegisteredUsers() {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.registeredUsers),
              let users = try? JSONDecoder().decode([DS_UserModel].self, from: data) else {
            registeredUsers = []
            return
        }
        registeredUsers = users.map { user in
            let migrated = UserData.migrateUserMediaPaths(user)
            guard let preset = UserData.user(userId: user.userId) else { return migrated }
            return UserData.mergingPresetComments(into: migrated, preset: preset)
        }
        saveRegisteredUsers()
    }

    private func restoreSessionIfNeeded() {
        guard let userId = UserDefaults.standard.string(forKey: StorageKey.loggedInUserId) else {
            return
        }

        if let registered = registeredUsers.first(where: { $0.userId == userId }) {
            let migrated = UserData.migrateUserMediaPaths(registered)
            if let preset = UserData.user(userId: userId) {
                user = UserData.mergingPresetComments(into: migrated, preset: preset)
            } else {
                user = migrated
            }
            loadHiddenPostIds(for: userId)
            loadBlacklistedUserIds(for: userId)
            return
        }

        if let preset = UserData.users.first(where: { $0.userId == userId }) {
            user = preset
            loadHiddenPostIds(for: userId)
            loadBlacklistedUserIds(for: userId)
        }
    }
}

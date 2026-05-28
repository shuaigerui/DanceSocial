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

    private enum StorageKey {
        static let registeredUsers = "ds_registered_users"
        static let loggedInUserId = "ds_logged_in_user_id"
        static let followByUserId = "ds_follow_by_user_id"
    }

    private(set) var user: DS_UserModel?

    var isLoggedIn: Bool {
        user != nil
    }

    private var registeredUsers: [DS_UserModel] = []
    private var followByUserId: [String: Bool] = [:]

    private init() {
        loadRegisteredUsers()
        loadFollowStates()
        restoreSessionIfNeeded()
    }

    // MARK: - Sign in

    @discardableResult
    func signIn(account: String, password: String) -> Bool {
        let email = account.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !email.isEmpty, !password.isEmpty else { return false }

        if email == Self.reviewAccount.lowercased(), password == Self.reviewPassword {
            let base = UserData.users[0]
            let user = registeredUsers.first(where: { $0.userId == base.userId }) ?? base
            configure(with: user)
            enterMainInterface()
            return true
        }

        if let preset = UserData.users.first(where: {
            $0.account.lowercased() == email && $0.password == password
        }) {
            let user = registeredUsers.first(where: { $0.userId == preset.userId }) ?? preset
            configure(with: user)
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
        self.user = user
        UserDefaults.standard.set(user.userId, forKey: StorageKey.loggedInUserId)

        if saveToRegisteredList {
            upsertRegisteredUser(user)
        }
    }

    func signOut() {
        user = nil
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
                videoCoverUrl: post.videoCoverUrl
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
        return applyingStoredFollowState(to: base)
    }

    // MARK: - Follow

    /// 切换关注状态并写入本地
    @discardableResult
    func toggleFollow(userId: String, isFollow: Bool) -> Bool {
        let newValue = !isFollow
        followByUserId[userId] = newValue
        saveFollowStates()

        if let registered = registeredUsers.first(where: { $0.userId == userId }) {
            upsertRegisteredUser(user(registered, isFollow: newValue))
        }
        return newValue
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
        guard let path = user.avatarUrl else { return nil }
        if path.hasPrefix("/") || path.hasPrefix("file://") {
            let url = URL(fileURLWithPath: path.replacingOccurrences(of: "file://", with: ""))
            return UIImage(contentsOfFile: url.path)
        }
        if let bundleURL = UserData.mediaFileURL(path: path) {
            return UIImage(contentsOfFile: bundleURL.path)
        }
        return nil
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
        return fileURL.path
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
            return fileURL.path
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
            guard let path, path.hasPrefix("/") else { return }
            try? FileManager.default.removeItem(atPath: path)
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
            if sourceURL.path == fileURL.path {
                return fileURL.path
            }
            try fileManager.copyItem(at: sourceURL, to: fileURL)
            return fileURL.path
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
            return fileURL.path
        } catch {
            return nil
        }
    }

    // MARK: - Persistence

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

    private func loadRegisteredUsers() {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.registeredUsers),
              let users = try? JSONDecoder().decode([DS_UserModel].self, from: data) else {
            registeredUsers = []
            return
        }
        registeredUsers = users
    }

    private func restoreSessionIfNeeded() {
        guard let userId = UserDefaults.standard.string(forKey: StorageKey.loggedInUserId) else {
            return
        }

        if let registered = registeredUsers.first(where: { $0.userId == userId }) {
            user = registered
            return
        }

        if let preset = UserData.users.first(where: { $0.userId == userId }) {
            user = preset
        }
    }
}

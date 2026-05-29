//
//  DS_ChatStore.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/29.
//

import Foundation

enum DS_ChatMessageSenderKind: String, Codable {
    case peer
    case me
}

struct DS_ChatStoredMessage: Codable {
    let messageId: String
    let sender: DS_ChatMessageSenderKind
    let text: String
    let createdAt: TimeInterval
}

struct DS_ChatConversation: Codable {
    let peerUserId: String
    var peerUserName: String
    var peerAvatarUrl: String?
    var messages: [DS_ChatStoredMessage]
    var hasUnread: Bool
}

/// 私信会话本地存储（按当前登录用户分桶）
enum DS_ChatStore {

    private static func storageKey(for currentUserId: String) -> String {
        "ds_chat_conversations_\(currentUserId)"
    }

    static func conversationThreadId(currentUserId: String, peerUserId: String) -> String {
        [currentUserId, peerUserId].sorted().joined(separator: "|")
    }

    static func messages(
        currentUserId: String,
        peerUserId: String
    ) -> [DS_ChatRoomMessage] {
        loadConversations(currentUserId: currentUserId)
            .first { $0.peerUserId == peerUserId }?
            .messages
            .map(DS_ChatRoomMessage.init(stored:)) ?? []
    }

    @discardableResult
    static func appendMessage(
        currentUserId: String,
        contact: DS_ChatRoomContact,
        sender: DS_ChatMessageSenderKind,
        text: String
    ) -> DS_ChatStoredMessage {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = DS_ChatStoredMessage(
            messageId: "m_\(UUID().uuidString.prefix(8))",
            sender: sender,
            text: trimmed,
            createdAt: Date().timeIntervalSince1970
        )

        var conversations = loadConversations(currentUserId: currentUserId)
        if let index = conversations.firstIndex(where: { $0.peerUserId == contact.userId }) {
            conversations[index].peerUserName = contact.name
            conversations[index].peerAvatarUrl = contact.avatarImageName
            conversations[index].messages.append(message)
            conversations[index].hasUnread = false
        } else {
            conversations.append(
                DS_ChatConversation(
                    peerUserId: contact.userId,
                    peerUserName: contact.name,
                    peerAvatarUrl: contact.avatarImageName,
                    messages: [message],
                    hasUnread: false
                )
            )
        }
        saveConversations(conversations, currentUserId: currentUserId)
        return message
    }

    static func markConversationRead(currentUserId: String, peerUserId: String) {
        var conversations = loadConversations(currentUserId: currentUserId)
        guard let index = conversations.firstIndex(where: { $0.peerUserId == peerUserId }) else {
            return
        }
        conversations[index].hasUnread = false
        saveConversations(conversations, currentUserId: currentUserId)
    }

    static func deleteConversation(currentUserId: String, peerUserId: String) {
        var conversations = loadConversations(currentUserId: currentUserId)
        conversations.removeAll { $0.peerUserId == peerUserId }
        saveConversations(conversations, currentUserId: currentUserId)
    }

    /// 删除账号时清空该用户的全部私信记录
    static func purgeAll(currentUserId: String) {
        UserDefaults.standard.removeObject(forKey: storageKey(for: currentUserId))
    }

    static func chatMessageItems(currentUserId: String) -> [DS_ChatMessageItem] {
        loadConversations(currentUserId: currentUserId)
            .filter { !$0.messages.isEmpty }
            .sorted { ($0.messages.last?.createdAt ?? 0) > ($1.messages.last?.createdAt ?? 0) }
            .compactMap { conversation -> DS_ChatMessageItem? in
                guard let last = conversation.messages.last else { return nil }
                return DS_ChatMessageItem(
                    userId: conversation.peerUserId,
                    avatarImageName: conversation.peerAvatarUrl,
                    name: conversation.peerUserName,
                    date: formattedDate(last.createdAt),
                    message: last.text,
                    hasUnread: conversation.hasUnread
                )
            }
    }

    private static func loadConversations(currentUserId: String) -> [DS_ChatConversation] {
        guard let data = UserDefaults.standard.data(forKey: storageKey(for: currentUserId)),
              let decoded = try? JSONDecoder().decode([DS_ChatConversation].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func saveConversations(_ conversations: [DS_ChatConversation], currentUserId: String) {
        guard let data = try? JSONEncoder().encode(conversations) else { return }
        UserDefaults.standard.set(data, forKey: storageKey(for: currentUserId))
    }

    private static func formattedDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

extension DS_ChatRoomMessage {

    init(stored: DS_ChatStoredMessage) {
        sender = stored.sender == .me ? .me : .peer
        text = stored.text
    }
}

extension DS_ChatRoomContact {

    init(user: DS_UserModel) {
        userId = user.userId
        name = user.userName
        avatarImageName = user.avatarUrl
    }

    init(friend: DS_ChatFriendItem) {
        userId = friend.userId
        name = friend.name
        avatarImageName = friend.avatarImageName
    }

    init(messageItem: DS_ChatMessageItem) {
        userId = messageItem.userId
        name = messageItem.name
        avatarImageName = messageItem.avatarImageName
    }
}

//
//  DS_GroupRoomScripts.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/28.
//

import Foundation

/// 6 个聊天室各 10 条万能话术（按房间下标 0~5）
enum DS_GroupRoomScripts {

    static let welcomeMessage =
        "Welcome to VoChat, please use the civilized language, release any vulgar, fraudulent, illegal information will be banned account."

    static let randomMemberNames: [String] = [
        "Victoria", "Chris", "Emma", "Leo", "Mia", "Noah", "Zoe", "Kai",
        "Olivia", "Ethan", "Ava", "Lucas", "Sophia", "Mason", "Isabella",
        "Marceline", "Luna", "Beach", "Nana", "Trending"
    ]

    private static let phrasesByRoomIndex: [[String]] = [
        [
            "What games are you all playing? Share!",
            "The beat tonight is incredible!",
            "Anyone up for a freestyle battle?",
            "Love the energy in this room!",
            "Drop your favorite dance move!",
            "Who's leading the next round?",
            "This vibe is everything!",
            "Let's keep the chat friendly!",
            "Tag your dance partner here!",
            "Ready when the music drops!"
        ],
        [
            "Hip-hop or jazz tonight?",
            "Stretch before you dance, friends!",
            "Sharing my new choreography soon.",
            "The floor looks amazing from here.",
            "Count me in for the next song!",
            "Great tips everyone, thank you!",
            "Who brought this playlist? Fire!",
            "Smile and move — that's the rule!",
            "Any beginners here? Welcome!",
            "Let's hype each other up!"
        ],
        [
            "Beach party mode activated!",
            "Sunset session was so fun yesterday.",
            "Sand or studio — where do you dance?",
            "Sending good vibes to the crew!",
            "Who's filming today? Share clips!",
            "Hydrate between sets, dancers!",
            "This room feels like summer!",
            "Jump in — we're just chatting!",
            "Favorite summer track go!",
            "Keep it positive and dance on!"
        ],
        [
            "Nana's crew checking in!",
            "Elegant lines or sharp hits tonight?",
            "Practice makes progress, not perfect.",
            "Cheering for everyone's growth!",
            "What song should we play next?",
            "Mirror work really helps, try it!",
            "So proud of this community.",
            "New here? Say hi below!",
            "Sharing gratitude for this space.",
            "Let's end the night strong!"
        ],
        [
            "Trending moves only in here!",
            "Did you see that combo? Wow!",
            "Who's going live after this?",
            "Drop a emoji if you're dancing!",
            "Challenge accepted — watch this!",
            "Algorithm blessed us tonight.",
            "Clip it or it didn't happen!",
            "Room full of talent, I swear.",
            "One more song before sleep?",
            "Stay safe and keep creating!"
        ],
        [
            "Welcome to our dance hangout!",
            "Introduce yourself in one line!",
            "Music on, worries off.",
            "Collaboration requests open!",
            "Respect the host and each other.",
            "What's your go-to warm-up?",
            "Lighting looks great on everyone.",
            "Pause for water — then back to it!",
            "Memories start in rooms like this.",
            "See you on the dance floor!"
        ]
    ]

    static func phrases(forRoomIndex index: Int) -> [String] {
        let safeIndex = min(max(index, 0), phrasesByRoomIndex.count - 1)
        return phrasesByRoomIndex[safeIndex]
    }
}

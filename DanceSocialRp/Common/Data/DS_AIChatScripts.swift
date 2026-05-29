//
//  DS_AIChatScripts.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/29.
//

import Foundation

/// AI 舞蹈助手话术（仅当前会话使用，不持久化）
enum DS_AIChatScripts {

    static let welcomeMessage =
        "Hi, I'm your AI dance assistant. Feel free to ask me any dance questions or other concerns."

    static let replyPhrases: [String] = [
        "Great question! Start with a solid warm-up and practice the basic groove on beat before adding layers.",
        "For cleaner isolations, slow the music down, drill each body part separately, then combine at half speed.",
        "Musicality tip: listen for the snare or hi-hat — hit your accents there and breathe in the gaps.",
        "If you're learning choreography, break it into 8-count chunks and master one section before moving on.",
        "Footwork looking heavy? Bend your knees slightly, stay on the balls of your feet, and lighten your landings.",
        "Freestyle block? Pick one emotion or one instrument in the track and let that drive your movement choices.",
        "Flexibility and strength both matter — add 10 minutes of stretching after every session.",
        "Filming yourself helps: you'll spot timing issues and posture habits you miss in the mirror.",
        "Pick shoes with good grip for your floor type — slippery soles make balance and turns much harder.",
        "Most importantly, stay consistent. Short daily practice beats one long session once a week."
    ]

    static func randomReply() -> String {
        replyPhrases.randomElement() ?? replyPhrases[0]
    }

    static var randomReplyDelay: TimeInterval {
        TimeInterval.random(in: 2...6)
    }
}

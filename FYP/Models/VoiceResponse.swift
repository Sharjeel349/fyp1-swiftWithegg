//
//  VoiceResponse.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 22/04/2026.
//

import Foundation
import Combine
import SwiftUI

// 1. Create a model to decode the API response
struct VoiceResponse: Codable ,Equatable{
    let userText: String
    let botText: String
    let userAudioUrl: String
    let botAudioUrl: String
    let emotion: String
    
    // Map the Swift variables to your Python JSON keys
    enum CodingKeys: String, CodingKey {
        case userText = "user_text"
        case botText = "bot_text"
        case userAudioUrl = "user_audio_url"
        case botAudioUrl = "bot_audio_url"
        case emotion = "user_emotion"
    }
}
enum Emotion: String {
    case neutral = "Neutral"
    case calm = "CALM"
    case stressed = "STRESSED"
}

func getColor(for emotion: String) -> UIColor {
    switch Emotion(rawValue: emotion) {
    case .neutral:
        return .black
    case .calm:
        return .green
    default:
        return .red
    }
}

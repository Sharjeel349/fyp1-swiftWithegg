//
//  Message.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 12/02/2026.
//

import Foundation
import SwiftUI
import Combine

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let time: String
    let isCurrentUser: Bool
    let textColor: String
    
    var actualColor: Color {
        switch textColor.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "gr/Users/sharjeelahmed/Desktop/XvMuseeen": return .green
        case "yellow": return .yellow
        case "white": return .white
        default: return .black // Fallback color
        }
    }
}

struct APIChatMessage: Codable {
    let message_id: Int
    let sender: String
    let message_text: String?
    let timestamp: String?
    let emotion: String
}

//
//  ChatSession.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//

import Foundation
import Combine

struct ChatSession: Codable, Identifiable {
    let id: Int
    let title: String
    let startTime: String
    
    // Maps your Python snake_case to Swift camelCase
    enum CodingKeys: String, CodingKey {
        case id = "session_id"
        case title
        case startTime = "start_time"
    }
}

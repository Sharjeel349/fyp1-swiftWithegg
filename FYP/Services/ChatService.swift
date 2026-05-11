//
//  ChatService.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//

import Foundation
import Combine
struct NewSessionResponse: Codable {
    let session_id: Int
    let title: String?
    // swiftlint:disable identifier_name
    // (If your JSON keys use underscores, make sure your struct matches!)
}

// MARK: - Service
class ChatService {
    static let shared = ChatService()
    private let network = NetworkManager() // Using your existing NetworkManager
    
    // Route: /student/{student_id}/chat-sessions
    func fetchChatSessions(studentId: String) async throws -> [ChatSession] {
        let data = try await network.request(url: "/student/\(studentId)/chat-sessions", method: "GET")
        return try JSONDecoder().decode([ChatSession].self, from: data)
    }
    
    // Route: /chat/{session_id}/messages
//    func fetchMessages(for sessionId: Int) async throws -> [ChatMessage] {
//        let data = try await network.request(url: "/chat/\(sessionId)/messages", method: "GET")
//        return try JSONDecoder().decode([ChatMessage].self, from: data)
//    }
    func fetchMessages(for sessionId: Int) async throws -> [ChatMessage] {
            // 1. Get the data
            let data = try await network.request(url: "/chat/\(sessionId)/messages", method: "GET")
            
            // 2. Decode it into the Bridge Model (This works because the keys match Python exactly!)
            let apiMessages = try JSONDecoder().decode([APIChatMessage].self, from: data)
            
            // Formatter for the time
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "hh:mm a"
            
            // 3. Translate the API data into your UI Bubbles
            var uiMessages: [ChatMessage] = []
            
            for msg in apiMessages {
                let isUser = (msg.sender == "User")
                let text = msg.message_text ?? ""
                let emotion = msg.emotion
                
                var timeString = ""
                if let timeRaw = msg.timestamp,
                   let cleanRaw = timeRaw.components(separatedBy: ".").first,
                   let date = inputFormatter.date(from: cleanRaw) {
                    timeString = outputFormatter.string(from: date)
                }
                
                // Create the SwiftUI bubble
                let chatBubble = ChatMessage(
                    text: text,
                    time: timeString,
                    isCurrentUser: isUser,
                    textColor: isUser ? emotion=="Neutral" ? "black" :
                        emotion=="CALM" ? "green" : "red"
                        : "black"
                    
                )
                
                uiMessages.append(chatBubble)
            }
            
            return uiMessages
        }
    
    func createNewSession(studentId: String) async throws -> Int {
            // Create the JSON body
            let requestBody: [String: Any] = [
                "student_id": studentId,
                "title": "New Advisor Session"
            ]
            
            // Make the POST request
            let data = try await network.request(url: "/chat-sessions", method: "POST", body: requestBody)
            
            // Decode the data to grab the new session_id
            let newSession = try JSONDecoder().decode(NewSessionResponse.self, from: data)
            
            return newSession.session_id
        }
    
//    func saveMessage(sessionId: Int, sender: String, text: String, voiceFile: String) async throws {
//        let requestBody: [String: Any] = [
//            "sender": sender,
//            "message_text": text,
//            "voice_file": voiceFile
//        ]
//        
//        _ = try await network.request(url: "/chat/\(sessionId)/messages", method: "POST", body: requestBody)
//    }
}

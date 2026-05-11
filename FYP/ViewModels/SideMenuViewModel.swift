//
//  SideMenuViewModel.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class SideMenuViewModel: ObservableObject {
    @Published var chatSessions: [ChatSession] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadHistory() async {
        // 1. Grab the student ID that we saved during Login
        guard let studentId = UserDefaults.standard.string(forKey: "student_id") else {
            errorMessage = "No Student ID found. Please log in again."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 2. Fetch the data from the API
            chatSessions = try await ChatService.shared.fetchChatSessions(studentId: studentId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Optional Helper: Converts raw database timestamps into nice UI strings like "Feb 10"
    func formatFriendlyDate(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // If your Python backend sends a standard ISO timestamp:
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM dd" // e.g., "Feb 10"
            return displayFormatter.string(from: date)
        }
        // Fallback if parsing fails
        return String(dateString.prefix(10))
    }
}

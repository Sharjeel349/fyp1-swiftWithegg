
//
//  ProfileViewModel.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: StudentProfile? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadProfile() async {
        guard let studentId = UserDefaults.standard.string(forKey: "student_id") else {
            errorMessage = "No Student ID found. Please log in again."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await ProfileService.shared.fetchProfile(studentId: studentId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

//
//  LoginViewModel.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 27/03/2026.
//
import Foundation
import SwiftUI
import Combine 
@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var selectedRole = "Student"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var navigateToHome = false
    
    func performLogin() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await AuthService.shared.login(email: email, password: password)
            print("Successfully logged in as: \(response.name)")
            navigateToHome = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

//
//  AuthService.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 27/03/2026.
//

import Foundation
import Combine
class AuthService {
    static let shared = AuthService()
    private let network = NetworkManager()
    func login(email:String, password:String) async throws -> AuthResponse{
        let body: [String: Any] = [
            "email":email,
            "password":password
        ]
    let data = try await network.request(url: "/auth/login", method: "POST", body: body)
    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
    if let studentId = authResponse.studentId {
            UserDefaults.standard.set(studentId, forKey: "student_id")
        }
        return authResponse
    }
}
            


